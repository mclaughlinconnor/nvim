local lsp_status = require("lsp-status")

return {
  capabilities = lsp_status.capabilities,
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
      diagnostics = {
        globals = { "vim", "use", "s", "sn", "i", "rep", "c", "d", "f", "t", "fmta", "fmt" },
        ignoredFiles = "Opened",
      },
      hint = {
        enable = true,
      },
      format = {
        enable = false,
      },
      -- Setup tailored for lua in neovim
      runtime = { version = "LuaJIT" },
      telemetry = { enable = false },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
}
