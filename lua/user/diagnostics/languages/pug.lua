local javascript = require("user.diagnostics.languages.javascript")
local utils = require("user.diagnostics.utils")

local M = {}

function M.is_interpolation(content)
  return content:match("%{%{.*%}%}")
end

function M.is_angular_attr(attr)
  return attr:match("%[.*%]") or attr:match("%(.*%)") or attr:match("%*.*")
end

function M.extract_interpolation_content(node, content)
  local raw_interpolation = vim.treesitter.get_node_text(node, content)
  local len = raw_interpolation:len()
  return raw_interpolation:sub(3, len - 2)
end

function M.extract_identifiers_from_content(node, content, on_identifier)
  local tag_content = vim.treesitter.get_node_text(node, content)
  if M.is_interpolation(tag_content) then
    for angular_content_node in utils.iter_captures("interpolation", tag_content, nil, "angular_content") do
      local interpolation_content = M.extract_interpolation_content(angular_content_node, tag_content)
      javascript.extract_js_identifiers(interpolation_content, on_identifier)
    end
  end
end

function M.extract_identifiers_from_attr(node, content, on_identifier)
  local name = vim.treesitter.get_node_text(node[1], content)
  local value = node[2]

  if M.is_angular_attr(name) then
    local value_text = vim.treesitter.get_node_text(value, content)

    javascript.extract_js_identifiers(value_text, on_identifier)
  end
end

function M.extract_pug_identifiers(filename, usages)
  local on_identifier = function(node, text)
    local var = vim.treesitter.get_node_text(node[1], text)
    usages[var] = true
  end

  utils.with_file_contents(filename, function(contents)
    local root = utils.create_string_parser(contents, "pug")

    for node in utils.iter_captures("content", contents, root) do
      M.extract_identifiers_from_content(node, contents, on_identifier)
    end

    for node in utils.iter_matches("attributes", contents, root) do
      M.extract_identifiers_from_attr(node, contents, on_identifier)
    end
  end)
end

return M
