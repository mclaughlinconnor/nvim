local diagnostics = require("user.diagnostics.diagnostics")
local pug = require("user.diagnostics.languages.pug")
local typescript = require("user.diagnostics.languages.typescript")
local utils = require("user.diagnostics.utils")

local function handle_class(name, source, root, file_path, start, stop)
  local usages = {}
  local variable_definitions = {}
  local getter_definitions = {}
  local decorators = {}

  local function extract_ts_identifiers()
    local function on_usage(node)
      local var = vim.treesitter.get_node_text(node, source)
      usages[var] = { is_public = false }
    end

    local function on_getter(node)
      typescript.add_method_definition(node, source, getter_definitions)
    end
    local function on_property_definition(node)
      typescript.add_method_definition(node, source, variable_definitions)
    end

    typescript.extract_ts_identifiers(source, root, on_getter, on_property_definition, on_usage, start, stop)
  end

  for node in utils.iter_matches("class_decorator", source, root, nil, start, stop) do
    local decorator_name = vim.treesitter.get_node_text(node[1], source)
    table.insert(decorators, decorator_name)
  end

  local has_template, pug_filename = utils.find_template(file_path, root)

  extract_ts_identifiers()
  if has_template then
    pug.extract_pug_identifiers(pug_filename, usages)
  end

  return {
    decorators = decorators,
    file_path = file_path,
    getter_definitions = getter_definitions,
    has_template = has_template,
    usages = usages,
    variable_definitions = variable_definitions,
  }
end

local function find_unused(ts_bufnr)
  local classes = {}
  local file_path = vim.api.nvim_buf_get_name(ts_bufnr)

  local ts_root = utils.create_buffer_parser(ts_bufnr, "typescript")

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
    diagnostics.build_diagnostics_for_class(file_diagnostics, class, class.has_template)
  end

  diagnostics.set_diagnostics(ts_bufnr, file_diagnostics)
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
