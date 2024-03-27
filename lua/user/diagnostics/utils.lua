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

function M.find_template(bufnr, root)
  local relative_template_path = ""
  local controller_directory = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")

  for node in M.iter_matches("template", bufnr, root) do
    relative_template_path = vim.treesitter.get_node_text(node[3], bufnr)
  end

  if relative_template_path == "" then
    return false, nil
  end

  return true, controller_directory .. "/" .. relative_template_path
end

function M.with_file_contents(filename, cb)
  local file = io.open(filename, "r")

  if file == nil then
    cb(nil)
    return
  end

  local contents = file:read("*all")
  cb(contents)

  file:close()
end

function M.iter_captures(query, content, tree, language)
  if tree == nil then
    if type(content) == "string" then
      tree = M.create_string_parser(content, language)
    else
      tree = M.create_buffer_parser(content, language)
    end
  end

  local original = queries[query]:iter_captures(tree, content, 0, -1)
  return function()
    local _, node = original()
    if node then
      return node
    end
  end
end

function M.iter_matches(query, content, tree, language)
  if tree == nil then
    if type(content) == "string" then
      tree = M.create_string_parser(content, language)
    else
      tree = M.create_buffer_parser(content, language)
    end
  end

  local original = queries[query]:iter_matches(tree, content, 0, -1)
  return function()
    local _, node = original()
    if node then
      return node
    end
  end
end

return M
