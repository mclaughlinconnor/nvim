local SERVERITY = require("user.diagnostics.severity")
local queries = require("user.diagnostics.queries")

local M = {}

function M.create_string_parser(text, language)
  local parser = vim.treesitter.get_string_parser(text, language)
  local tree = parser:parse()[1]:root()

  return tree
end

function M.create_buffer_parser(bufnr, language)
  local parser = vim.treesitter.get_parser(bufnr, language)
  local tree = parser:parse()[1]:root()

  return tree
end

function M.generate_diagnostic(message, node, pug_bufnr, s)
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

function M.find_template(file_path, root)
  local controller_directory = vim.fn.fnamemodify(file_path, ":h")

  local relative_template_path = M.with_file_contents(file_path, function(contents)
    for node in M.iter_matches("component_decorator", contents, root) do
      return vim.treesitter.get_node_text(node[3], contents)
    end
  end)

  if relative_template_path == nil then
    return nil
  end

  return controller_directory .. "/" .. relative_template_path
end

function M.with_file_contents(filename, cb)
  local file = io.open(filename, "r")

  if file == nil then
    cb(nil)
    return
  end

  local contents = file:read("*all")
  file:close()

  return cb(contents)
end

function M.iter_captures(query, content, tree, language, start_, stop_)
  local start = start_ or 0
  local stop = stop_ or -1

  if tree == nil then
    if type(content) == "string" then
      tree = M.create_string_parser(content, language)
    else
      tree = M.create_buffer_parser(content, language)
    end
  end

  local original = queries[query]:iter_captures(tree, content, start, stop)
  return function()
    local _, node = original()
    if node then
      return node
    end
  end
end

function M.iter_matches(query, content, tree, language, start_, stop_)
  local start = start_ or 0
  local stop = stop_ or -1

  if tree == nil then
    if type(content) == "string" then
      tree = M.create_string_parser(content, language)
    else
      tree = M.create_buffer_parser(content, language)
    end
  end

  local original = queries[query]:iter_matches(tree, content, start, stop)
  return function()
    local _, node = original()
    if node then
      return node
    end
  end
end

return M
