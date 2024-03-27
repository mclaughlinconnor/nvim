local attributes = [[
  (attribute
    (attribute_name) @name
    (quoted_attribute_value
      (attribute_value) @value))
]]

local content = [[
  (content) @content
]]

local interpolation = [[
  (interpolation) @interpolation
]]

local identifiers = [[
  (identifier) @name
]]

local property_definition = [[
  (public_field_definition
    (accessibility_modifier) @accessibility_modifier
    name: (property_identifier) @var) @definition
]]

local getter_definition = [[
  (method_definition
    (accessibility_modifier) @accessibility_modifier
    "get"
    name: (property_identifier) @var)
]]

local property_usage = [[
  (member_expression
    object: (this)
    property: (property_identifier) @var)
]]

local template = [[
  (decorator
    (call_expression
      function: (identifier) @decorator_name
      arguments: (arguments
        (object
          (pair
             key: (property_identifier) @key_name
             value: (string (string_fragment) @template)
          )
        )
      )
    )
    (#eq? @key_name "templateUrl")
    (#eq? @decorator_name "Component")
  )
]]

local disallowed_decorators = {
  ["Attribute"] = true,
  ["Component"] = true,
  ["ContentChild"] = true,
  ["ContentChildren"] = true,
  ["Directive"] = true,
  ["Host"] = true,
  ["HostBinding"] = true,
  ["HostListener"] = true,
  ["Inject"] = true,
  ["Injectable"] = true,
  ["Input"] = true,
  ["NgModule"] = true,
  ["Optional"] = true,
  ["Output"] = true,
  ["Pipe"] = true,
  ["Self"] = true,
  ["SkipSelf"] = true,
  ["ViewChild"] = true,
  ["ViewChildren"] = true,
}

local SERVERITY = vim.lsp.protocol.DiagnosticSeverity

local function find_unused(ts_bufnr)
  -- var: ispublic
  local usages = {}
  local variable_definitions = {}
  local getter_definitions = {}

  local ts_parser = vim.treesitter.get_parser(ts_bufnr, "typescript")
  local ts_tree = ts_parser:parse()[1]
  local ts_root = ts_tree:root()

  local diagnostics_namespace = vim.api.nvim_create_namespace("unused-public-diagnostics")

  local function extract_pug_identifiers(pug_bufnr)
    local pug_parser = vim.treesitter.get_parser(pug_bufnr, "pug")

    local pug_tree = pug_parser:parse()[1]
    local pug_root = pug_tree:root()

    local attr_query = vim.treesitter.query.parse("pug", attributes)
    local content_query = vim.treesitter.query.parse("pug", content)
    local interpolation_query = vim.treesitter.query.parse("angular_content", interpolation)
    local js_query = vim.treesitter.query.parse("javascript", identifiers)

    local extract_js_identifiers = function(text)
      local js_parser = vim.treesitter.get_string_parser(text, "javascript")
      local js_tree = js_parser:parse()[1]:root()

      for _, node in js_query:iter_matches(js_tree, text, 0, -1) do
        local var = vim.treesitter.get_node_text(node[1], text)
        usages[var] = true
      end
    end

    for _, node in content_query:iter_captures(pug_root, pug_bufnr, 0, -1) do
      local tag_content = vim.treesitter.get_node_text(node, pug_bufnr)

      if tag_content:match("%{%{.*%}%}") then
        local angular_content_parser = vim.treesitter.get_string_parser(tag_content, "angular_content")
        local angular_content_tree = angular_content_parser:parse()[1]:root()

        for _, angular_content_node in interpolation_query:iter_captures(angular_content_tree, tag_content, 0, -1) do
          local raw_interpolation = vim.treesitter.get_node_text(angular_content_node, tag_content)
          local len = raw_interpolation:len()
          local interpolation_content = raw_interpolation:sub(3, len - 2)

          extract_js_identifiers(interpolation_content)
        end
      end
    end

    for _, node in attr_query:iter_matches(pug_root, pug_bufnr, 0, -1) do
      local name = vim.treesitter.get_node_text(node[1], pug_bufnr)
      local value = node[2]

      if name:match("%[.*%]") or name:match("%(.*%)") or name:match("%*.*") then
        local value_text = vim.treesitter.get_node_text(value, pug_bufnr)

        extract_js_identifiers(value_text)
      end
    end
  end

  local function extract_ts_identifiers()
    local definitions_query = vim.treesitter.query.parse("typescript", property_definition)
    local getter_definition_query = vim.treesitter.query.parse("typescript", getter_definition)
    local usages_query = vim.treesitter.query.parse("typescript", property_usage)

    local function add_nodes(nodes, defs)
      local is_public = vim.treesitter.get_node_text(nodes[1], ts_bufnr) == "public"
      local var = vim.treesitter.get_node_text(nodes[2], ts_bufnr)
      defs[var] = { is_public = is_public, node = nodes[2], used = false }
    end

    for _, node in getter_definition_query:iter_matches(ts_root, ts_bufnr, 0, -1) do
      add_nodes(node, getter_definitions)
    end

    for _, node in definitions_query:iter_matches(ts_root, ts_bufnr, 0, -1) do
      local prev_node = node[3]:prev_named_sibling()
      if prev_node ~= nil and prev_node:type() == "decorator" then
        local first_child = prev_node:named_child(0)

        local decorator_name = nil
        if first_child ~= nil then
          if first_child:type() == "call_expression" then
            decorator_name = vim.treesitter.get_node_text(first_child:field("function")[1], ts_bufnr)
          elseif first_child:type() == "identifier" then
            decorator_name = vim.treesitter.get_node_text(first_child, ts_bufnr)
          end
        end

        print(decorator_name)

        if decorator_name ~= nil and not disallowed_decorators[decorator_name] then
          add_nodes(node, variable_definitions)
        end
      else
        add_nodes(node, variable_definitions)
      end
    end

    for _, node in usages_query:iter_captures(ts_root, ts_bufnr, 0, -1) do
      local var = vim.treesitter.get_node_text(node, ts_bufnr)
      usages[var] = false
    end
  end

  local function find_template()
    local relative_template = ""
    local controller_directory = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ts_bufnr), ":h")

    local template_query = vim.treesitter.query.parse("typescript", template)
    for _, node in template_query:iter_matches(ts_root, ts_bufnr, 0, -1) do
      relative_template = vim.treesitter.get_node_text(node[3], ts_bufnr)
    end

    if relative_template == "" then
      return -1
    end

    local template_path = controller_directory .. "/" .. relative_template

    local bufnr = vim.fn.bufnr(template_path)
    if bufnr == -1 then
      vim.fn.bufadd(template_path)
    end

    bufnr = vim.fn.bufnr(template_path)

    return bufnr
  end

  local pug_bufnr = find_template()

  local function generate_diagnostic(message, node, s)
    local severity = s or SERVERITY.Warning

    local lnum, col, end_lnum, end_col = node:range()
    local formatted_message = message

    if pug_bufnr == -1 then
      formatted_message = "[NP] " .. message
    end

    return {
      lnum = lnum,
      col = col,
      end_lnum = end_lnum,
      end_col = end_col,
      message = formatted_message,
      severity = severity,
    }
  end

  extract_ts_identifiers()
  if pug_bufnr ~= -1 then
    extract_pug_identifiers(pug_bufnr)
  end

  local diagnostics = {}

  for var, definition in pairs(getter_definitions) do
    if usages[var] == true then
      table.insert(diagnostics, generate_diagnostic("Getter used in template: " .. var, definition.node, SERVERITY.Hint))
    end
  end

  for var, definition in pairs(variable_definitions) do
    local node = definition.node
    local definition_is_public = definition.is_public
    local usage = usages[var]

    -- tsserver covers this unused variables already
    if definition_is_public then
      if usage == nil then
        table.insert(diagnostics, generate_diagnostic("Unused public variable: " .. var, node))
      elseif usage == false then
        table.insert(diagnostics, generate_diagnostic("Needlessly public variable: " .. var, node))
      end
    end
  end

  vim.diagnostic.set(diagnostics_namespace, ts_bufnr, diagnostics)

  if vim.fn.buflisted(pug_bufnr) == 0 and pug_bufnr ~= -1 then
    vim.cmd.bwipeout(pug_bufnr)
  end
end

vim.keymap.set("n", "<leader>vs", function()
  find_unused(0)
end)

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
  callback = function(event)
    find_unused(event.buf)
  end,
  group = vim.api.nvim_create_augroup("UnusedPublicDefinitions", {}),
  pattern = { "*.ts" },
})

-- todo: make this into a general purpose framework to find angular templates, etc.
-- The plan is to eventually index the entire project using something like this
