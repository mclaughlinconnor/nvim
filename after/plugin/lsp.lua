local lsp_status = require("lsp-status")
lsp_status.register_progress()

-- these are not lsp specific mappings
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- do this only on attached buffers
local on_attach = function(client, bufnr)
  lsp_status.on_attach(client)

  if client.name == "tsserver" then
		client.server_capabilities.document_formatting = false
	end

  -- lsp specific mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "g0", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "<space>f", function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)
end

local mason = require("mason")
mason.setup({})

-- I don't use the angularls installed by mason
require("lspconfig").angularls.setup({
  on_attach = on_attach,
  capabilities = lsp_status.capabilities,
  filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "pug" },
  cmd = { "ngserverPUG", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" }
})

require("null-ls").setup({
  -- you can reuse a shared lspconfig on_attach callback here
  on_attach = on_attach,
  debug = true,
  sources = {
    require("null-ls").builtins.completion.spell,
    require("null-ls").builtins.formatting.latexindent.with({
      filetypes = { "tex", "latex" },
    }),
    require("null-ls").builtins.diagnostics.eslint_d,
    require("null-ls").builtins.code_actions.eslint_d,
    require("null-ls").builtins.formatting.eslint_d,
    require("null-ls").builtins.formatting.fixjson,
    require("null-ls").builtins.diagnostics.luacheck,
    require("null-ls").builtins.diagnostics.proselint,
    require("null-ls").builtins.diagnostics.puglint,
    require("null-ls").builtins.diagnostics.shellcheck,
    require("null-ls").builtins.diagnostics.todo_comments,
    require("null-ls").builtins.diagnostics.trail_space,
    require("null-ls").builtins.formatting.trim_whitespace,
    require("null-ls").builtins.diagnostics.yamllint.with({
      extra_args = {
        -- we don't need --- at document start
        "-d",
        "{rules: {line-length: disable, document-start: disable}}",
      },
    }),
    -- require("null-ls").builtins.formatting.yamlfmt,
    require("null-ls").builtins.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),
  },
})

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers({
  -- handle all servers without specific handlers
  function(server_name)
    require("lspconfig")[server_name].setup({
      on_attach = on_attach,
    })
  end,
  ["tsserver"] = function()
    require("lspconfig").tsserver.setup({
      on_attach = on_attach,
      capabilities = lsp_status.capabilities,
      init_options = {
        preferences = {
          importModuleSpecifierPreference = "relative",
        },
      },
    })
  end,
  ["sumneko_lua"] = function()
    require("lspconfig")["sumneko_lua"].setup({
      capabilities = lsp_status.capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          -- Setup tailored for lua in neovim
          runtime = { version = "LuaJIT" },
          diagnostics = {
            globals = {
              "vim",
              "s",
              "sn",
              "t",
              "i",
              "f",
              "c",
              "d",
              "isn",
              "l",
              "dl",
              "rep",
              "r",
              "p",
              "types",
              "events",
              "util",
              "fmt",
              "fmta",
              "ls",
              "ins_generate",
              "parse",
              "n",
              "m",
              "ai",
              "visual_wrap",
              "multiline_visual_wrap",
            },
          },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          telemetry = { enable = false },
        },
      },
    })
  end,
})
