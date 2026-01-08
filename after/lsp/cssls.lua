local lsp_status = require("lsp-status")

local capabilities = lsp_status.capabilities
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
  capabilities = capabilities,
}
