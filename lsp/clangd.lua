local lsp_status = require("lsp-status")

return {
  capabilities = lsp_status.capabilities,
  cmd = { "clangd", "--background-index", "--clang-tidy" },
}
