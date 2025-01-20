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

  if client.name == "tsserver" or client.name == "vtsls" then
    client.server_capabilities.documentFormattingProvider = false
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
  vim.keymap.set("n", "<C-K>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set(
    "i",
    "<C-k>",
    function()
      local ls = require("luasnip")
      if ls and ls.jumpable(1) then
        ls.jump(-1)
      else
        vim.lsp.buf.signature_help()
      end
    end,
    bufopts
  )
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

local tsInspector = vim.lsp.start_client({
  cmd = {"/Users/connorveryconnect.com/Downloads/ts_inspector/ts_inspector"},
  root_dir = vim.fn.getcwd(),
  -- Update below too
  on_attach = on_attach,
  filetypes = { "typescript", "pug" },
  name="ts_inspector"
})

if not tsInspector then
  vim.notify("tsInspector couldn't attach")
else
  vim.api.nvim_create_autocmd("FileType", {
    -- Update above too
    pattern = { "typescript", "pug" },
    callback = function()
      vim.lsp.buf_attach_client(0, tsInspector)
    end,
  })
end


local ijInspector = vim.lsp.start_client({
  cmd = vim.lsp.rpc.connect('127.0.0.1', 2517),
  root_dir = vim.fn.getcwd(),
  -- Update below too
  filetypes = { "typescript", "javascript", "html", "scss", "sass", "css", "less", "pug", "java", "kotlin" },
  on_attach = on_attach,
  name = "ij_inspector",
})

if not ijInspector then
  vim.notify("ijInspector couldn't attach")
else
  vim.api.nvim_create_autocmd("FileType", {
    -- Update above too
    pattern = { "typescript", "javascript", "html", "scss", "sass", "css", "less", "pug", "java", "kotlin"},
    callback = function()
      vim.lsp.buf_attach_client(0, ijInspector)
    end,
  })
end


-- Stolen from https://github.com/MariaSolOs/dotfiles/blob/6eeaff6701d6470f1b8432f6a800679faac59367/.config/nvim/lua/lsp.lua#L259
local md_namespace = vim.api.nvim_create_namespace 'mariasolos/lsp_float'
local function add_inline_highlights(buf)
    for l, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        for pattern, hl_group in pairs {
            ['@%S+'] = '@parameter',
            ['^%s*(Parameters:)'] = '@text.title',
            ['^%s*(Return:)'] = '@text.title',
            ['^%s*(See also:)'] = '@text.title',
            ['{%S-}'] = '@parameter',
            ['|%S-|'] = '@text.reference',
        } do
            local from = 1 ---@type integer?
            while from do
                local to
                from, to = line:find(pattern, from)
                if from then
                    vim.api.nvim_buf_set_extmark(buf, md_namespace, l - 1, from - 1, {
                        end_col = to,
                        hl_group = hl_group,
                    })
                end
                from = to and to + 1 or nil
            end
        end
    end
end

--- HACK: Override `vim.lsp.util.stylize_markdown` to use Treesitter.
---@param bufnr integer
---@param contents string[]
---@param opts table
---@return string[]
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util._stylize_markdown = function(bufnr, contents, opts)
  contents = vim.tbl_map(function(line)
    local escapes = {
      ['&gt;'] = '>',
      ['&lt;'] = '<',
      ['&quot;'] = '"',
      ['&apos;'] = "'",
      ['&ensp;'] = ' ',
      ['&emsp;'] = ' ',
      ['&nbsp;'] = ' ',
      ['&#32;'] = ' ',
      ['&amp;'] = '&',
    }
    return (string.gsub(line, '&[^ ;]+;', escapes))
  end, contents)
  contents = vim.lsp.util._normalize_markdown(contents, {
    width = vim.lsp.util._make_floating_popup_size(contents, opts),
  })
  vim.bo[bufnr].filetype = 'markdown'
  vim.treesitter.start(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

  add_inline_highlights(bufnr)

  return contents
end
-- End theft

local stylize_markdown = vim.lsp.util.stylize_markdown
vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
  contents = vim.tbl_map(function(line)
    local escapes = {
      ['&gt;'] = '>',
      ['&lt;'] = '<',
      ['&quot;'] = '"',
      ['&apos;'] = "'",
      ['&ensp;'] = ' ',
      ['&emsp;'] = ' ',
      ['&nbsp;'] = ' ',
      ['&#32;'] = ' ',
      ['&amp;'] = '&',
    }
    return (string.gsub(line, '&[^ ;]+;', escapes))
  end, contents)
 
  stylize_markdown(bufnr, contents, opts)
end

local uri_to_bufnr = vim.uri_to_bufnr
vim.uri_to_bufnr = function(uri, opts)
  -- Call the original function to get the buffer number
  local bufnr = uri_to_bufnr(uri, opts)
  
  -- Check if this is a URI you want to intercept
  if uri:match(".*%.class") then
    -- Set your custom content
    local lines = {"// This file is a compiled Java class file. It should be decompiled. It is not."}
    for _ = 0, 2000 do
      table.insert(lines, "                                                                                                                                                                                                         ")
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    
    -- Set the buffer as unmodified
    vim.api.nvim_buf_set_option(bufnr, 'modified', false)
    
    -- Optionally, set the buffer type to nofile if you don't want it associated with a file
    -- vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  end
  
  return bufnr
end

return {
  {
    "williamboman/mason.nvim",
    commit = "fc98833b6da5de5a9c5b1446ac541577059555be",
    config = function()
      -- Seems to be required
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    commit = "1a31f824b9cd5bc6f342fc29e9a53b60d74af245",
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
        ["cssls"] = function()
          local capabilities = lsp_status.capabilities
          capabilities.textDocument.completion.completionItem.snippetSupport = true
          require("lspconfig")["cssls"].setup({
            capabilities = capabilities,
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
        ["vtsls"] = function()
          require("lspconfig").vtsls.setup({
            on_attach = on_attach,
            capabilities = lsp_status.capabilities,
            settings = {
              complete_function_calls = true,
              typescript = {
                enableMoveToFileCodeAction = true,
                referencesCodeLens = { enabled = false },
                implementationsCodeLens = { enabled = false },
                format = {
                  enable = false,
                  insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false, -- needed for imports to be formatted properly
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
                tsserver = {
                  enableRegionDiagnostics = true,
                },
                preferences = {
                preferTypeOnlyAutoImports = true,
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
            cmd = { "sg", "lsp", "--config", vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/misc/ast-grep/sgconfig.yml" },
            filetypes = { "typescript", "pug" },
          })
        end,
      })

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        -- delay update diagnostics
        update_in_insert = true,
        float = {
          border = "rounded",
        },
      })

      vim.lsp.handlers["textDocument/diagnostic"] = vim.lsp.with(vim.lsp.diagnostic.on_diagnostic, {
        update_in_insert = true,
        float = {
          border = "rounded",
        },
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
    commit = "7af2c37192deae28d1305ae9e68544f7fb5408e1",
  },
}
