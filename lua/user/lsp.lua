local lsp_status = require('lsp-status')
lsp_status.register_progress()

-- these are not lsp specific mappings
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- do this only on attached buffers
local on_attach = function(client, bufnr)
  lsp_status.on_attach(client)

  -- lsp specific mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function ()
    vim.lsp.buf.format({async = true})
  end, bufopts)
end

local mason = require("mason")
mason.setup {}

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  -- handle all servers without specific handlers
  function(server_name)
    require("lspconfig")[server_name].setup {}
  end,
  ['angularls'] = function()
    require("lspconfig")['angularls'].setup {
      on_attach = on_attach,
      capabilities = lsp_status.capabilities,
      -- add pug so my patched lang server will get called
      filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "pug" },
    }
  end,
  ['sumneko_lua'] = function()
    require('lspconfig')['sumneko_lua'].setup {
      capabilities = lsp_status.capabilities,
      settings = {
        Lua = {
          -- Setup tailored for lua in neovim
          runtime = { version = 'LuaJIT', },
          diagnostics = { globals = { 'vim' }, },
          workspace = { library = vim.api.nvim_get_runtime_file("", true), },
          telemetry = { enable = false, },
        },
      },
    }
  end,
}
