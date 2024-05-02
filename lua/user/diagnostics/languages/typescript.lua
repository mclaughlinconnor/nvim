local angular_decorators = require("user.diagnostics.angular_decorators")
local queries = require("user.diagnostics.queries")
local utils = require("user.diagnostics.utils")

local M = {}

function M.find_getters(source, root, cb, start, stop)
  for node in utils.iter_matches("getter_definition", source, root, nil, start, stop) do
    cb(node)
  end
end

function M.is_angular_decorator(decorator_name)
  return angular_decorators[decorator_name]
end

function M.extract_ts_identifiers(
  source,
  root,
  on_getter,
  on_property_definition,
  on_usage,
  on_constructor_usage,
  start,
  stop
)
  M.find_getters(source, root, function(node)
    on_getter(node)
  end, start, stop)

  for node in utils.iter_matches("property_definition", source, root, nil, start, stop) do
    -- todo: add data for if it's overriding something on the parent
    local is_angular_decorator = false
    local has_decorator = node[1] ~= nil
    if has_decorator then
      local decorator_name = vim.treesitter.get_node_text(node[1], source)
      is_angular_decorator = M.is_angular_decorator(decorator_name)
    end

    if has_decorator then
      if not is_angular_decorator then
        on_property_definition(node)
      end
    else
      on_property_definition(node)
    end
  end

  for node in utils.iter_matches("constructor", source, root, nil, start, stop) do
    local body = node[2]
    for usage in utils.iter_captures("property_usage", source, root, nil, body:start(), body:end_()) do
      on_constructor_usage(usage)
    end
  end

  for node in utils.iter_captures("property_usage", source, root, nil, start, stop) do
    on_usage(node)
  end

  for node in utils.iter_captures("prototype_usage", source, root, nil, start, stop) do
    on_usage(node)
  end
end

function M.extract_imports(source, root, on_import)
  for node in utils.iter_matches("import", source, root) do
    local import = {}

    import.is_type = node[1] ~= nil
    import.path = vim.treesitter.get_node_text(node[3], source)
    else
      import.path = path
    end

    for specifier in node[2]:iter_children() do
      if specifier:named() then
        if import.identifiers == nil then
          import.identifiers = {}
        end

        local identifier = specifier:field("name")
        local alias = specifier:field("alias")

        table.insert(import.identifiers, {
          identifier = vim.treesitter.get_node_text(identifier[1], source),
          alias = #alias ~= 0 and vim.treesitter.get_node_text(alias[1], source) or nil,
        })
      end
    end

    on_import(import)
  end
end

-- Does this make sense as a method in this file?
function M.add_method_definition(nodes, source, tab)
  local accessibility = vim.treesitter.get_node_text(nodes[2], source)
  local var = vim.treesitter.get_node_text(nodes[3], source)
  tab[var] = { accessibility = accessibility, node = nodes[4] }
end

function M.add_getter_definition(nodes, source, tab)
  local accessibility = vim.treesitter.get_node_text(nodes[1], source)
  local var = vim.treesitter.get_node_text(nodes[2], source)
  tab[var] = { accessibility = accessibility, node = nodes[4] }
end

return M
