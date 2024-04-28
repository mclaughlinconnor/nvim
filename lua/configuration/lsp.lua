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

return {
  {
    "williamboman/mason.nvim",
    commit = "41e75af1f578e55ba050c863587cffde3556ffa6",
    config = function()
      -- Seems to be required
      require("mason").setup()
    end,
  },
  {
    -- Hacky: should come before lspconfig so ast-grep's actions come first
    "jose-elias-alvarez/null-ls.nvim",
    commit = "0010ea927ab7c09ef0ce9bf28c2b573fc302f5a7",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local null_ls = require("null-ls")

      return {
        on_attach = on_attach,
        debug = true,
        sources = {
          null_ls.builtins.formatting.latexindent.with({
            filetypes = { "tex", "latex" },
          }),
          null_ls.builtins.formatting.fixjson,
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.stylelint.with({
            extra_args = {
              "--config",
              ---@diagnostic disable-next-line: param-type-mismatch
              vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/stylelint.config.js",
            },
          }),
          null_ls.builtins.diagnostics.todo_comments,
          null_ls.builtins.diagnostics.trail_space,
          null_ls.builtins.formatting.trim_whitespace,
          null_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          }),
          null_ls.builtins.formatting.clang_format,
        },
      }
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
      {
        "pmizio/typescript-tools.nvim",
        commit = "7911a0aa27e472bff986f1d3ce38ebad3b635b28",
        requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      },
    },
    config = function()
      local lsp_status = require("lsp-status")

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
          require("typescript-tools").setup({
            code_lens = "off", -- need to patch a newer version of angularls to support them
            on_attach = on_attach,
            capabilities = lsp_status.capabilities,
            settings = {
              complete_function_calls = true,
              expose_as_code_action = "all",
              tsserver_file_preferences = {
                importModuleSpecifierPreference = "relative",
                includeCompletionsForImportStatements = true,
                includeCompletionsForModuleExports = true,
                includeCompletionsWithSnippetText = true,
                includeInlayEnumMemberValueHints = true, -- enum {ONE /* = 0 */, TWO /* = 1 */,}
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = false, -- no need for `.then(r /* ResultInterface[] */ => handleResult(r))`
                includeInlayParameterNameHints = "literals", -- only show inlay hints for literal values being passed
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                quotePreference = "single",
              },
              tsserver_format_options = {
                insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false,
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
    commit = "694aaec65733e2d54d393abf80e526f86726c988",
    config = function()
      local lsp_status = require("lsp-status")

      require("lspconfig")["angularls"].setup({
        on_attach = on_attach,
        capabilities = lsp_status.capabilities,
        filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "pug" },
        cmd = angularls_config(vim.loop.fs_realpath(".")),
        on_new_config = function(new_config, new_root_dir)
          new_config.cmd = angularls_config(new_root_dir)
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    commit = "f20f35756e74b91c0b4340d01fee22422bdffefa",
    config = function()
      local lint = require("lint")

      require("lint").linters_by_ft = {
        scss = { "stylelint" },
        css = { "stylelint" },
        less = { "stylelint" },
      }
      local stylelint = require("lint").linters.stylelint
      stylelint.args = {
        "-f",
        "json",
        "--config",
        function()
          return vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/stylelint.config.js"
        end,
        "--stdin",
        "--stdin-filename",
        function()
          return vim.fn.expand("%:p")
        end,
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
