-- these are not lsp specific mappings
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- do this only on attached buffers
local function on_attach(client, bufnr)
  local fzf = require("fzf-lua")
  require("lsp-status").on_attach(client)

  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
  end

  if client.server_capabilities.inlayHintProvider then
    vim.keymap.set("n", "<space>gi", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(0))
    end)
    vim.lsp.inlay_hint.enable(true)
  end

  vim.keymap.set("n", "<space>gd", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  end)

  -- lsp specific mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", fzf.lsp_implementations, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gli", fzf.lsp_implementations, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", fzf.lsp_typedefs, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", fzf.lsp_code_actions, bufopts)
  vim.keymap.set("n", "gr", fzf.lsp_references, bufopts)
  vim.keymap.set("n", "g0",
    function()
      vim.lsp.buf.code_action({ context = {
        diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr),
        only = {
          -- "", -- Empty -- Adding this makes some of tsservers actions disappear
          "quickfix", -- QuickFix
          "refactor", -- Refactor
          "refactor.extract", -- RefactorExtract
          "refactor.inline", -- RefactorInline
          "refactor.rewrite", -- RefactorRewrite
          "source", -- Source
          "source.organizeImports", -- SourceOrganizeImports
          "source.fixAll", -- SourceFixAll
        },
      } })
    end,
    bufopts)
  vim.keymap.set("v", "g0", fzf.lsp_code_actions, bufopts)
  vim.keymap.set("n", "<space>f", function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)
end

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
    "ngserver",
    "--stdio",
    "--tsProbeLocations",
    locations,
    "--ngProbeLocations",
    locations,
  }
end

local client = vim.lsp.start_client({
  cmd = { "/Users/connorveryconnect.com/Downloads/ts_inspector/ts_inspector" },
  on_attach = on_attach,
  name = "ts_inspector",
})

if not client then
  vim.notify("Client didn't start")
else
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "pug" },
    callback = function()
      vim.lsp.buf_attach_client(0, client)
    end,
  })
end

return {
  {
    "williamboman/mason.nvim",
    commit = "751b1fcbf3d3b783fcf8d48865264a9bcd8f9b10",
    config = function()
      -- Seems to be required
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    commit = "4eb8e15e3c0757303d4c6dea64d2981fc679e990",
    dependencies = {
      "williamboman/mason.nvim",
      "ibhagwan/fzf-lua",
      "neovim/nvim-lspconfig",
      "nvim-cmp",
      {"yioneko/nvim-vtsls", commit = "45c6dfea9f83a126e9bfc5dd63430562b3f8af16"},
      -- {
      --   "pmizio/typescript-tools.nvim",
      --   commit = "7911a0aa27e472bff986f1d3ce38ebad3b635b28",
      --   requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      -- },
    },
    config = function()
      local lsp_status = require("lsp-status")

      require("lspconfig.configs").vtsls = require("vtsls").lspconfig

      require("mason-lspconfig").setup_handlers({
        -- handle all servers without specific handlers
        function(server_name)
          require("lspconfig")[server_name].setup({
            on_attach = on_attach,
          })
        end,
        ["clangd"] = function()
          require("lspconfig")["clangd"].setup({
            capabilities = lsp_status.capabilities,
            cmd = { "clangd", "--background-index", "--clang-tidy" },
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
          require("lspconfig").vtsls.setup({
            on_attach = on_attach,
            capabilities = lsp_status.capabilities,
            settings = {
              complete_function_calls = true,
              typescript = {
                referencesCodeLens = { enabled = false },
                implementationsCodeLens = { enabled = false },
                format = {
                  insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false,
                },
                inlayHints = {
                  enumMemberValues = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  parameterNames = {
                    enabled = "literals",
                    suppressWhenArgumentMatchesName = true,
                  },
                  parameterTypes = { enabled = false },
                  propertyDeclarationTypes = {
                    enabled = true,
                    suppressWhenArgumentMatchesName = true,
                  },
                  variableTypes = { enabled = true },
                },
                suggest = {
                  classMemberSnippets = { enabled = true },
                  objectLiteralMethodSnippets = { enabled = true },
                  completeFunctionCalls = true,
                  includeAutomaticOptionalChainCompletions = true,
                  includeCompletionsWithSnippetText = true,
                  includeCompletionsForImportStatements = true,
                },
                preferences = {
                  importModuleSpecifier = "relative",
                  quoteStyle = "single",
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
          })
        end,
        ["ast_grep"] = function()
          require("lspconfig")["ast_grep"].setup({
            cmd = { "sg", "lsp" },
            filetypes = { "typescript", "pug" },
            single_file_support = true,
            root_dir = function()
              return vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/misc/ast-grep"
            end,
          })
        end,
      })

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        -- delay update diagnostics
        update_in_insert = true,
      })

      vim.lsp.handlers["textDocument/diagnostic"] = vim.lsp.with(vim.lsp.diagnostic.on_diagnostic, {
        update_in_insert = false,
      })
    end,
  },
  {
    "folke/neodev.nvim",
    commit = "1676d2c24186fc30005317e0306d20c639b2351b",
    dependencies = { "nvim-dap-ui" },
    opts = { library = { plugins = { "nvim-dap-ui" }, types = true } },
  },
  {
    "nvim-lua/lsp-status.nvim",
    commit = "54f48eb5017632d81d0fd40112065f1d062d0629",
    config = function()
      require("lsp-status").register_progress()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    commit = "dddd0945c0f31a0abd843425927a1712d2db2e10",
    config = function()
      -- local lsp_status = require("lsp-status")

      -- require("lspconfig")["angularls"].setup({
      --   on_attach = on_attach,
      --   capabilities = lsp_status.capabilities,
      --   filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "pug" },
      --   cmd = angularls_config(vim.loop.fs_realpath(".")),
      --   on_new_config = function(new_config, new_root_dir)
      --     new_config.cmd = angularls_config(new_root_dir)
      --   end,
      -- })
    end,
  },
  -- {
  --   "mfussenegger/nvim-lint",
  --   commit = "f20f35756e74b91c0b4340d01fee22422bdffefa",
  --   config = function()
  --     local lint = require("lint")
  --
  --     require("lint").linters_by_ft = {
  --       scss = { "stylelint" },
  --       css = { "stylelint" },
  --       less = { "stylelint" },
  --     }
  --     local stylelint = require("lint").linters.stylelint
  --     stylelint.args = {
  --       "-f",
  --       "json",
  --       "--config",
  --       function()
  --         return vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/stylelint.config.js"
  --       end,
  --       "--stdin",
  --       "--stdin-filename",
  --       function()
  --         return vim.fn.expand("%:p")
  --       end,
  --     }
  --
  --     vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
  --       group = vim.api.nvim_create_augroup("lint", { clear = true }),
  --       callback = function()
  --         lint.try_lint()
  --       end,
  --     })
  --   end,
  -- },
}
