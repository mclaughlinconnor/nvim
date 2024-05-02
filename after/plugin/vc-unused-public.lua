local ACCESSIBILITY = require("user.diagnostics.accessibility")
local diagnostics = require("user.diagnostics.diagnostics")
local pug = require("user.diagnostics.languages.pug")
local typescript = require("user.diagnostics.languages.typescript")
local utils = require("user.diagnostics.utils")

local function handle_class(name, source, root, file_path, start, stop)
  local usages = {}
  local variable_definitions = {}
  local getter_definitions = {}
  local decorators = {}

  if file_path:find("^diffview://") then
    return {
      decorators = {},
      file_path = file_path,
      getter_definitions = {},
      template = nil,
      usages = {},
      variable_definitions = {},
    }
  end

  local function extract_ts_identifiers()
    local function on_constructor_usage(node)
      local var = vim.treesitter.get_node_text(node, source)
      usages[var] = { access = ACCESSIBILITY.Access.Local, constructor_only = true, node = node }
    end

    local function on_usage(node)
      local var = vim.treesitter.get_node_text(node, source)

      if usages[var] ~= nil and usages[var].constructor_only and usages[var].node:id() == node:id() then
        return
      end

      usages[var] = { access = ACCESSIBILITY.Access.Local, node = node }
    end

    local function on_getter(node)
      typescript.add_getter_definition(node, source, getter_definitions)
    end
    local function on_property_definition(node)
      typescript.add_method_definition(node, source, variable_definitions)
    end

    typescript.extract_ts_identifiers(
      source,
      root,
      on_getter,
      on_property_definition,
      on_usage,
      on_constructor_usage,
      start,
      stop
    )
  end

  for node in utils.iter_matches("class_decorator", source, root, nil, start, stop) do
    local decorator_name = vim.treesitter.get_node_text(node[1], source)
    table.insert(decorators, decorator_name)
  end

  local pug_filename = utils.find_template(file_path, root, start, stop)

  extract_ts_identifiers()
  if pug_filename ~= nil then
    pug.extract_pug_identifiers(pug_filename, usages)
  end

  return {
    decorators = decorators,
    file_path = file_path,
    getter_definitions = getter_definitions,
    template = pug_filename,
    usages = usages,
    variable_definitions = variable_definitions,
  }
end

local function find_unused(ts_bufnr)
  local classes = {}
  local file_path = vim.api.nvim_buf_get_name(ts_bufnr)

  local ts_root = utils.create_buffer_parser(ts_bufnr, "typescript")

  typescript.extract_imports(ts_bufnr, ts_root, function(import)
    print(vim.inspect(import))
  end)

  for node in utils.iter_matches("class_definition", ts_bufnr, ts_root) do
    local name = node[1]
    local startRow, _, _ = node[2]:start()
    local stopRow, _, _ = node[2]:end_()

    table.insert(
      classes,
      handle_class(vim.treesitter.get_node_text(name, ts_bufnr), ts_bufnr, ts_root, file_path, startRow, stopRow)
    )
  end

  local file_diagnostics = {}
  for _, class in ipairs(classes) do
    diagnostics.build_diagnostics_for_class(file_diagnostics, class, class.template ~= nil)
  end

  diagnostics.set_diagnostics(ts_bufnr, file_diagnostics)
local function update_all_buffers()
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tabpage)

  local bufnrs = {}

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    table.insert(bufnrs, buf)
  end

  for _, bufnr in ipairs(bufnrs) do
    find_unused(bufnr)
  end
end

vim.keymap.set("n", "<leader>vs", function()
  update_all_buffers()
end)

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
  callback = function()
    local ok = pcall(update_all_buffers)
    if not ok then
      vim.notify("[PUG] Error updating buffers' diagnostics")
      diagnostics.reset_diagnostics()
    end
  end,
  group = vim.api.nvim_create_augroup("UnusedPublicDefinitions", {}),
  pattern = { "*.ts", "*.pug" },
})

-- todo: make this into a general purpose framework to find angular templates, etc.
-- The plan is to eventually index the entire project using something like this
