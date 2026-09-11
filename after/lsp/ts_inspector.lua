local timeout_ms = 500
local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

local function showLocations(err, result)
  assert(not err, vim.inspect(err))
  local locations = result

  if not locations or #locations == 0 then
    print("No locations found")
    return
  end

  if #locations == 1 then
    vim.lsp.util.show_document(locations[1], "utf-8")
    return
  end

  local items = vim.lsp.util.locations_to_items(locations, "utf-8")
  local fzf_entries = {}

  local make_entry = require("fzf-lua.make_entry")
  local fzf_opts = require("fzf-lua.config").globals

  for _, item in ipairs(items) do
    item.filename = vim.fn.fnamemodify(item.filename, ":.")
    table.insert(fzf_entries, make_entry.lcol(item, fzf_opts))
  end

  require("fzf-lua").fzf_exec(fzf_entries, {
    prompt = "Review findings > ",
    previewer = "builtin",
    actions = {
      ["ctrl-q"]  = require("fzf-lua.actions").file_sel_to_qf,
      ["ctrl-s"]  = require("fzf-lua.actions").file_split,
      ["ctrl-t"]  = require("fzf-lua.actions").file_tabedit,
      ["ctrl-v"]  = require("fzf-lua.actions").file_vsplit,
      ["default"] = require("fzf-lua.actions").file_edit,
    }
  })
end

vim.lsp.handlers['ts_inspector/showLocations'] = showLocations

-- Based on https://github.com/mfussenegger/nvim-jdtls/blob/2c84b72ded8789ff3d78f5ad11710e3b45bec6d6/lua/jdtls.lua#L1186-L1237
function view_tcb(fname)
  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].modifiable = true
  -- vim.bo[buf].swapfile = false
  -- vim.bo[buf].buftype = 'nowrite'
  -- This triggers FileType event which should fire up the lsp client if not already running
  vim.bo[buf].filetype = 'typescript'

  vim.wait(timeout_ms, function()
    return next(get_clients({ name = "ts_inspector" })) ~= nil
  end)
  local client = get_clients({ name = "ts_inspector" })[1]

  assert(client, 'Must have a `ts_inspector` client to load template TCB')

  local content
  local function handler(err, result)
    assert(not err, vim.inspect(err))
    content = result
    local normalized = string.gsub(result, '\r\n', '\n')
    local source_lines = vim.split(normalized, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)
    vim.bo[buf].modifiable = false
  end

  local params = {uri = fname}
  client:request("ts_inspector/getTcb", params, handler, buf)

  -- Need to block. Otherwise logic could run that sets the cursor to a position
  -- that's still missing.
  vim.wait(timeout_ms, function() return content ~= nil end)
end

local group = vim.api.nvim_create_augroup("ts_inspector", {})
vim.api.nvim_create_autocmd("BufReadCmd", {
  group = group,
  pattern = "*.ts_inspector-tcb.ts",
  callback = function (args)
    print("view tcb")
    view_tcb(args.match)
  end
})

return {
  cmd = {"/home/connor/Development/ts_inspector/ts_inspector"},
  root_dir = vim.fn.getcwd(),
  filetypes = { "typescript", "pug" },
  name="ts_inspector"
}
