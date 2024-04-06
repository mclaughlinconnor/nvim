local SERVERITY = require("user.diagnostics.severity")
local utils = require("user.diagnostics.utils")

local M = {}

local diagnostics_namespace = vim.api.nvim_create_namespace("unused-public-diagnostics")

function M.build_diagnostics_for_class(file_diagnostics, class, has_template)
  local bufnr = vim.fn.bufnr(class.file_path)
  if bufnr == -1 or bufnr == nil then
    return
  end

  local getters = class.getter_definitions
  local usages = class.usages
  local vars = class.variable_definitions

  for var, definition in pairs(getters) do
    if usages[var] and usages[var].is_public == true then
      table.insert(
        file_diagnostics,
        utils.generate_diagnostic("Getter used in template: " .. var, definition.node, has_template, SERVERITY.Hint)
      )
    end
  end

  for var, definition in pairs(vars) do
    local node = definition.node
    local definition_is_public = definition.is_public
    local usage = usages[var]

    -- tsserver covers unused variables already
    if definition_is_public then
      if usage == nil then
        table.insert(file_diagnostics, utils.generate_diagnostic("Unused public variable: " .. var, node, has_template))
      elseif usage.is_public == false then
        table.insert(
          file_diagnostics,
          utils.generate_diagnostic("Needlessly public variable: " .. var, node, has_template)
        )
      end
    end
  end
end

function M.set_diagnostics(bufnr, diagnostics)
  vim.diagnostic.set(diagnostics_namespace, bufnr, diagnostics)
end

return M
