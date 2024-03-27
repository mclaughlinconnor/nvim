local angular_decorators = require("user.diagnostics.angular_decorators")
local utils = require("user.diagnostics.utils")

local M = {}

function M.find_getters(source, root, cb)
  for node in utils.iter_matches("getter_definition", source, root) do
    cb(node)
  end
end

function M.get_property_definition_decorator(nodes, source)
  local prev_node = nodes[3]:prev_named_sibling()
  if prev_node ~= nil and prev_node:type() == "decorator" then
    local first_child = prev_node:named_child(0)

    local decorator_name = nil
    if first_child ~= nil then
      if first_child:type() == "call_expression" then
        decorator_name = vim.treesitter.get_node_text(first_child:field("function")[1], source)
      elseif first_child:type() == "identifier" then
        decorator_name = vim.treesitter.get_node_text(first_child, source)
      end
    end

    return decorator_name, M.is_angular_decorator(decorator_name)
  end

  return nil, false
end

function M.is_angular_decorator(decorator_name)
  return angular_decorators[decorator_name]
end

function M.extract_ts_identifiers(source, root, on_getter, on_property_definition, on_usage)

  M.find_getters(source, root, function(node)
    on_getter(node)
  end)

  for node in utils.iter_matches("property_definition", source, root) do
    local decorator_name, is_angular_decorator = M.get_property_definition_decorator(node, source)
    if decorator_name ~= nil then
      if not is_angular_decorator then
        on_property_definition(node)
      end
    else
      on_property_definition(node)
    end
  end

  for node in utils.iter_captures("property_usage", source, root) do
    on_usage(node)
  end
end

-- Does this make sense as a method in this file?
function M.add_method_definition(nodes, source, tab)
  local is_public = vim.treesitter.get_node_text(nodes[1], source) == "public"
  local var = vim.treesitter.get_node_text(nodes[2], source)
  tab[var] = { is_public = is_public, node = nodes[2], used = false }
end

return M

