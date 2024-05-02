local SERVERITY = require("user.diagnostics.severity")
local queries = require("user.diagnostics.queries")

local M = {}

function M.create_parser(source, language)
  if type(source) == "string" then
    return M.create_string_parser(source, language)
  else
    return M.create_buffer_parser(source, language)
  end
end

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

function M.find_template(file_path, root, start, stop)
  local controller_directory = vim.fn.fnamemodify(file_path, ":h")

  local relative_template_path = M.with_file_contents(file_path, function(contents)
    for node in M.iter_matches("component_decorator", contents, root, nil, start, stop) do
      return vim.treesitter.get_node_text(node[3], contents)
    end
  end)

  if relative_template_path == nil then
    return nil
  end

  local filename = vim.fn.fnamemodify(controller_directory .. "/" .. relative_template_path, ":p")

  if M.file_exists(filename) then
    return filename
  end
end

function M.with_file_contents(filename, cb)
  -- todo: do something about diffview's diffview:// files
  filename = vim.fn.fnamemodify(filename, ":p")
  local content

  local bufnr = M.buffer_for_name(filename)
  -- unlisted buffers are usually (in my experience any way) from LSP
  if bufnr ~= nil and vim.bo[bufnr].buflisted then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    content = table.concat(lines, "\n")

    return cb(content)
  end

  local file = io.open(filename, "r")

  if file == nil then
    cb(nil)
    return
  end

  content = file:read("*all")
  file:close()

  return cb(content)
end

function M.iter_captures(query, content, tree, language, start_, stop_)
  local start = start_ or 0
  local stop = stop_ or -1

  if tree == nil then
    tree = M.create_parser(content, language)
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
    tree = M.create_parser(content, language)
  end

  local original = queries[query]:iter_matches(tree, content, start, stop)
  return function()
    local _, node = original()
    if node then
      return node
    end
  end
end

function M.buffer_for_name(filename)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == filename then
      return bufnr
    end
  end

  return nil
end

function M.path_is_relative(path)
  return path:sub(1, 1) == "."
end

function M.file_exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == "file"
end

return M
