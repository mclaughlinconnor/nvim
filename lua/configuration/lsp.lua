-- these are not lsp specific mappings
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- do this only on attached buffers
local on_attach = function(client, bufnr)
  local fzf = require("fzf-lua")
  require("lsp-status").on_attach(client)

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
    "williamboman/mason-lspconfig.nvim",
    commit = "4eb8e15e3c0757303d4c6dea64d2981fc679e990",
    dependencies = {
      "williamboman/mason.nvim",
      "ibhagwan/fzf-lua",
      "neovim/nvim-lspconfig",
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
          null_ls.builtins.diagnostics.eslint_d.with({
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
          null_ls.builtins.code_actions.eslint_d,
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.fixjson,
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.stylelint,
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
}
