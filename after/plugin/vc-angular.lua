local file_generators = require("user.component_generators")

local lir = require("lir")
local lir_actions = require("lir.actions")

local cwd = vim.loop.cwd()

local function find_buffer_by_name(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name == name then
      return buf
    end
  end
  return -1
end

-- Could probably have used vim.fs.find instead of this whole function
local find_modules
find_modules = function(directory, filename)
  directory = directory:gsub("/$", "") -- trailing slash messes with fnamemodify and root check
  local files_matching = vim.fn.split(vim.fn.globpath(directory, filename), "\n")

  if #files_matching > 0 then
    return files_matching
  end

  if directory == cwd then
    return nil
  end

  local parent = vim.fn.fnamemodify(directory, ":h")

  return find_modules(parent, filename)
end

local function find_module(callback)
  local context = lir.get_context()
  local modules = find_modules(context.dir, "*.module.ts")

  local relative_modules = {}
  ---@diagnostic disable-next-line: param-type-mismatch
  for _, module in ipairs(modules) do
    table.insert(relative_modules, vim.fn.fnamemodify(module, ":~:."))
  end

  if #relative_modules == 0 then
    vim.notify("No module found")
  elseif #relative_modules == 1 then
    callback(cwd .. "/" .. relative_modules[1])
  elseif #relative_modules > 1 then
    vim.ui.select(relative_modules, { prompt = "Which module?" }, function(choice)
      callback(cwd .. "/" .. choice)
    end)
  end
end

local function get_treesitter_root(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "typescript", {})
  local tree = parser:parse()[1]
  return tree:root()
end

local function update_module_arrays(bufnr, target_array, component)
  local query = vim.treesitter.query.parse(
    "typescript",
    [[
      (decorator
        (call_expression
          function: (identifier) @decorator_name
          arguments: (arguments
            (object
              (pair
                 key: (property_identifier) @keyname
                 value: (array) @values
              ) @pair
            )
          )
        )
      ) @decorator
      (#eq? @decorator_name "NgModule")
    ]]
  )

  local root = get_treesitter_root(bufnr)
  local changes = {}

  local add_to_array = function(node)
    -- { start_line, start_col, end_line, end_col }
    local range = { node:range() }
    local text = vim.treesitter.get_node_text(node, bufnr)

    if range[1] == range[3] then -- only one line
      local new_text = text:gsub("%W*]", ", " .. component .. "]")
      vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], { new_text })
    else
      local last_elem = node:named_child(node:named_child_count() - 1)
      local last_elem_range = { last_elem:range() }
      local last_line_content = vim.api.nvim_buf_get_lines(bufnr, last_elem_range[3], last_elem_range[3] + 1, false)[1]
      local spaces_indent = string.match(last_line_content, "%s*")

      local trailing_comma = ""
      if vim.treesitter.get_node_text(last_elem:next_sibling(), bufnr) == "," then
        trailing_comma = ","
      else
        vim.api.nvim_buf_set_lines(
          bufnr,
          last_elem_range[3],
          last_elem_range[3] + 1,
          false,
          { last_line_content .. "," }
        )
      end

      table.insert(changes, 1, {
        start = last_elem_range[3] + 1,
        final = last_elem_range[3] + 1,
        content = { spaces_indent .. component .. trailing_comma },
      })
    end
  end

  local updated = false
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "values" then
      local prev = node:prev_named_sibling()

      if prev == nil then
        goto continue
      end

      if vim.treesitter.get_node_text(prev, bufnr) == target_array then
        add_to_array(node)
        updated = true
      end
    end
    ::continue::
  end

  for _, change in ipairs(changes) do
    vim.api.nvim_buf_set_lines(bufnr, change.start, change.final, false, change.content)
  end

  if not updated then
    vim.notify("Couldn't update " .. target_array .. " in " .. vim.api.nvim_buf_get_name(bufnr))
  end
end

local function get_ts_client(module, component_name, callback)
  local bufnr = find_buffer_by_name(module)
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(bufnr, module)
    vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
  end
  vim.cmd.buffer(bufnr)

  update_module_arrays(bufnr, "declarations", component_name)

  local ts = vim.lsp.get_clients({ name = "typescript-tools" })
  if ts[1] ~= nil and ts[1].name == "typescript-tools" then
    vim.lsp.buf_attach_client(bufnr, ts[1].id)
    callback(bufnr)
  end

  vim.notify("Attempting to start tsserver...")
  vim.cmd("LspStart typescript-tools")

  return vim.defer_fn(function()
    callback(bufnr)
  end, 5000)
end

local function update_module(component_name, component_directory)
  find_module(function(module)
    vim.notify("Updating " .. module)

    get_ts_client(module, component_name, function(bufnr)
      vim.ui.select(
        { "Sharing is caring", "Keep it to ourselves" },
        { prompt = "Export from module?" },
        function(choice)
          if choice == "Sharing is caring" then
            update_module_arrays(bufnr, "exports", component_name)
          end

          require("typescript-tools.api").add_missing_imports(true)
          vim.cmd(":edit " .. component_directory .. "/..")
        end
      )
    end)
  end)
end

local function get_name(callback)
  vim.ui.input({ prompt = "What should the selector of your component be?" }, function(selector)
    callback((selector):gsub("^tg%-", ""):gsub(" ", "-"):lower())
  end)
end

local function make_directory(directory, selector)
  local path = directory .. "/" .. selector
  vim.fn.mkdir(path)

  return path
end

local function make_component(component_directory, component_class_name, selector)
  local extensions = { ".ts", ".scss", ".pug" }

  local fd
  for _, extension in ipairs(extensions) do
    local file_path = component_directory .. "/" .. selector .. ".component" .. extension

    fd = vim.loop.fs_open(file_path, "w+", 436)

    if fd == nil then
      vim.notify("Couldn't open " .. file_path)
      return
    end

    vim.loop.fs_write(fd, file_generators.the_only_type[extension](component_class_name, selector))
  end

  lir_actions.reload()
end

local lirAngular = vim.api.nvim_create_augroup("LirAngular", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function()
    vim.keymap.set("n", "<leader>vn", function()
      local lir_directory = lir.get_context().dir

      get_name(function(selector)
        local component_class_name = selector:gsub("-(.)", string.upper):gsub("^%l", string.upper) .. "Component"
        local component_directory = make_directory(lir_directory, selector)
        make_component(component_directory, component_class_name, selector)
        update_module(component_class_name, component_directory)
      end)
    end, { noremap = true, buffer = 0 })
  end,
  group = lirAngular,
  pattern = "lir",
})
