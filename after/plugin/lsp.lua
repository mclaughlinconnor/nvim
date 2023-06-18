require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

local lsp_status = require("lsp-status")
local fzf = require("fzf-lua")
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
  vim.keymap.set("n", "gli", fzf.lsp_implementations, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", fzf.lsp_typedefs, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", fzf.lsp_code_actions, bufopts)
  vim.keymap.set("n", "gr", fzf.lsp_references, bufopts)
  vim.keymap.set("n", "g0", fzf.lsp_code_actions, bufopts)
  vim.keymap.set("n", "<space>f", function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)
end

local mason = require("mason")
mason.setup({})

-- I don't use the angularls installed by mason
-- Ref: https://github.com/williamboman/mason.nvim/blob/4f5de77fab742ab2ca5512e7f3c9881cacdaf8eb/lua/nvim-lsp-installer/servers/angularls/init.lua

local function get_npm_root()
  return vim.fn.system("npm root"):gsub("\n", "")
end

local function get_npm_global_root()
  return vim.fn.system("npm root -g"):gsub("\n", "")
end

local function append_node_modules(dir)
  return table.concat({ dir, "node_modules" }, "/") -- will probably cause problems on windows
end

local function angularls_config(workspace_dir)
  local root_dir = vim.loop.fs_realpath(".")
  local locations = table.concat(
    { get_npm_global_root(), get_npm_root(), append_node_modules(root_dir), append_node_modules(workspace_dir) },
    ","
  )

  return {
    "ngserverPUG",
    "--stdio",
    "--tsProbeLocations",
    locations,
    "--ngProbeLocations",
    locations,
  }
end

require("lspconfig").angularls.setup({
  on_attach = on_attach,
  capabilities = lsp_status.capabilities,
  filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "pug" },
  cmd = angularls_config(vim.loop.fs_realpath(".")),
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = angularls_config(new_root_dir)
  end,
})

require("null-ls").setup({
  on_attach = on_attach,
  debug = true,
  sources = {
    require("null-ls").builtins.formatting.latexindent.with({
      filetypes = { "tex", "latex" },
    }),
    require("null-ls").builtins.diagnostics.eslint_d.with({
      condition = function(utils)
        return utils.root_has_file({
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.cjs",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          ".eslintrc.json",
        })
      end,
    }),
    require("null-ls").builtins.code_actions.eslint_d,
    require("null-ls").builtins.formatting.eslint_d,
    require("null-ls").builtins.formatting.fixjson,
    require("null-ls").builtins.diagnostics.luacheck,
    require("null-ls").builtins.diagnostics.shellcheck,
    require("null-ls").builtins.diagnostics.stylelint,
    require("null-ls").builtins.diagnostics.todo_comments,
    require("null-ls").builtins.diagnostics.trail_space,
    require("null-ls").builtins.formatting.trim_whitespace,
    require("null-ls").builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    require("typescript.extensions.null-ls.code-actions"),
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
  ["ltex"] = function()
    require("lspconfig")["ltex"].setup({
      on_attach = on_attach,
      settings = {
        ltex = {
          language = "en-GB",
          additionalRules = {
            enablePickyRules = true,
            motherTongue = "en-GB",
          },
          disabledRules = {
            ["en-GB"] = { "OXFORD_SPELLING_NOUNS" },
          },
          checkFrequency = "save",
        },
      },
    })
  end,
  ["tsserver"] = function()
    require("typescript").setup({
      server = {
        on_attach = on_attach,
        capabilities = lsp_status.capabilities,
        settings = {
          completions = {
            completeFunctionCalls = true,
          },
          typescript = {
            tsserver = {
              experimental = {
                enableProjectDiagnostics = true,
                completion = {
                  enableServerSideFuzzyMatch = true,
                  entriesLimit = 50,
                },
              },
            },
            experimental = {
              enableProjectDiagnostics = true,
              completion = {
                enableServerSideFuzzyMatch = true,
                entriesLimit = 50,
              },
            },
            format = {
              insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false,
            },
          },
        },
        init_options = {
          preferences = {
            importModuleSpecifierPreference = "relative",
            includePackageJsonAutoImports = "off,"
          },
        },
      },
    })
  end,
  ["lua_ls"] = function()
    require("lspconfig")["lua_ls"].setup({
      capabilities = lsp_status.capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          format = {
            enable = false,
          },
          -- Setup tailored for lua in neovim
          runtime = { version = "LuaJIT" },
          telemetry = { enable = false },
          workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
        },
      },
    })
  end,
})
