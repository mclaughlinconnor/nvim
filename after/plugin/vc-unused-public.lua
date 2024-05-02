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

local function find_unused(imports, classes, source, depth_, relative_root)
  local depth = depth_ or 0

  if depth >= 2 then
    return
  end

  local file_path
  if type(source) == "number" then
    file_path = vim.api.nvim_buf_get_name(source)
    if utils.path_is_relative(file_path) then
      file_path = relative_root .. "/" .. file_path
    end
  else
    local file = io.open(source, "r")
    if file == nil then
      return
    end

    file_path = source -- source is currently filename
    source = file:read("*all") -- replace with the file content which other functions already handle

    file:close()
  end

  local ts_root = utils.create_parser(source, "typescript")

  typescript.extract_imports(source, ts_root, file_path, function(import)
    if import.is_relative and depth < 2 then
      find_unused(imports, classes, import.path, depth + 1)
    end

    table.insert(imports, import)
  end)

  for node in utils.iter_matches("class_definition", source, ts_root) do
    local name = node[1]
    local startRow, _, _ = node[2]:start()
    local stopRow, _, _ = node[2]:end_()

    table.insert(
      classes,
      handle_class(vim.treesitter.get_node_text(name, source), source, ts_root, file_path, startRow, stopRow)
    )
  end

  local file_diagnostics = {}
  for _, class in ipairs(classes) do
    diagnostics.build_diagnostics_for_class(file_diagnostics, class, class.template ~= nil)
  end

  if type(source) == "number" then
    diagnostics.set_diagnostics(source, file_diagnostics)
  end
end

local function update_all_buffers()
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tabpage)

  local bufnrs = {}

  for _, win in ipairs(windows) do
    if vim.api.nvim_get_option_value("diff", { win = win }) == false then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if ft == "typescript" or ft == "pug" then
        table.insert(bufnrs, buf)
      end
    end
  end

  local imports = {}
  local classes = {}
  for _, bufnr in ipairs(bufnrs) do
    find_unused(imports, classes, bufnr)
  end

  return classes
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
-- Need to compile the pug so that vars used through pug interpolation still count as being used, though checking for strings in mixin params may be possible instead
-- Anywhere that uses with_file_contents needs to check if the file has a buffer, then use that buffer instead
-- broken: import {ChangeDetectionStrategy, Component/*  inject */} from '@angular/core';
-- wrap the full thing in a pcall
-- remember that propert declarations don't need an accessibility modifier
-- remember readonly too
