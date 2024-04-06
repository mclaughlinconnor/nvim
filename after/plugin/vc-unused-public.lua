local SERVERITY = require("user.diagnostics.severity")
local pug = require("user.diagnostics.languages.pug")
local typescript = require("user.diagnostics.languages.typescript")
local utils = require("user.diagnostics.utils")

local function find_unused(ts_bufnr)
  local usages = {}
  local variable_definitions = {}
  local getter_definitions = {}

  local ts_root = utils.create_buffer_parser(ts_bufnr, "typescript")

  local diagnostics_namespace = vim.api.nvim_create_namespace("unused-public-diagnostics")

  local function extract_ts_identifiers()
    local function on_usage(node)
      local var = vim.treesitter.get_node_text(node, ts_bufnr)
      usages[var] = { is_public = false }
    end

    local function on_getter(node)
      typescript.add_method_definition(node, ts_bufnr, getter_definitions)
    end
    local function on_property_definition(node)
      typescript.add_method_definition(node, ts_bufnr, variable_definitions)
    end

    typescript.extract_ts_identifiers(ts_bufnr, ts_root, on_getter, on_property_definition, on_usage)
  end

  local has_template, pug_filename = utils.find_template(ts_bufnr, ts_root)

  extract_ts_identifiers()
  if has_template then
    pug.extract_pug_identifiers(pug_filename, usages)
  end

  local diagnostics = {}

  for var, definition in pairs(getter_definitions) do
    if usages[var] and usages[var].is_public == true then
      table.insert(
        diagnostics,
        utils.generate_diagnostic("Getter used in template: " .. var, definition.node, has_template, SERVERITY.Hint)
      )
    end
  end

  for var, definition in pairs(variable_definitions) do
    local node = definition.node
    local definition_is_public = definition.is_public
    local usage = usages[var]

    -- tsserver covers unused variables already
    if definition_is_public then
      if usage == nil then
        table.insert(diagnostics, utils.generate_diagnostic("Unused public variable: " .. var, node, has_template))
      elseif usage.is_public == false then
        table.insert(diagnostics, utils.generate_diagnostic("Needlessly public variable: " .. var, node, has_template))
      end
    end
  end

  vim.diagnostic.set(diagnostics_namespace, ts_bufnr, diagnostics)
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
