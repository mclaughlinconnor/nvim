local timeout_ms = 500
local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

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
