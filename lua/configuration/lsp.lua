-- these are not lsp specific mappings
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

vim.g.copilot_node_command = "/Users/connorveryconnect.com/.nvm/versions/node/v20.19.2/bin/node"
vim.g.copilot_command = "/Users/connorveryconnect.com/vc/repos/vscode-inline-completion/server/out/server.js"

vim.lsp.log.set_level("TRACE")
vim.o.winborder = 'bold'

vim.diagnostic.config({
  float = {
    border = "rounded"
  }
})

-- do this only on attached buffers
local function on_attach(client, bufnr)
  local fzf = require("fzf-lua")
  require("lsp-status").on_attach(client)

  if client.name == "tsserver" or client.name == "vtsls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "ast_grep" then
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.hoverProvider = false
  end

  if client.name == "vcIc" then
    vim.api.nvim_create_autocmd({ "TextChangedI" }, {
      callback = function()
        vim.lsp.inline_completion.get()
      end,
      group = vim.api.nvim_create_augroup("InlineCompletion", {}),
    })

    vim.keymap.set(
      "i",
      "<Tab>",
      function() 
        local namespace_id = vim.api.nvim_get_namespaces()["nvim.lsp.inline_completion"]
        local extmarks = vim.api.nvim_buf_get_extmarks(0, namespace_id, 0, -1, {})
        if (not next(extmarks)) then
          return '<Tab>'
        end

        vim.lsp.inline_completion.get()
        return
      end,
      bufopts
    )



  end

  -- vim.notify("inlayHintProvider" .. vim.inspect(client.server_capabilities))
  -- if client.server_capabilities.inlayHintProvider then
  --   vim.keymap.set("n", "<space>gi", function()
  --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({bufnr = 0}))
  --   end)
  --   vim.lsp.inlay_hint.enable(false)
  -- end

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
          "", -- Empty -- Adding this makes some of tsservers actions disappear
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

vim.lsp.config('*', { on_attach = on_attach })

local border = {
  {"╭", "FloatBorder"},
  {"─", "FloatBorder"},
  {"╮", "FloatBorder"},
  {"│", "FloatBorder"},
  {"╯", "FloatBorder"},
  {"─", "FloatBorder"},
  {"╰", "FloatBorder"},
  {"│", "FloatBorder"},
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  -- delay update diagnostics
  update_in_insert = true,
  float = {
    border = border,
  },
})

vim.lsp.handlers["textDocument/diagnostic"] = vim.lsp.with(vim.lsp.diagnostic.on_diagnostic, {
  update_in_insert = true,
  float = {
    border = border
  },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = border
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = border,
})

return {
  {
    "mason-org/mason.nvim",
    commit = "v2.2.1",
    config = function()
      -- Seems to be required
      require("mason").setup()
    end,
  },
  {
    "https://github.com/mason-org/mason-lspconfig.nvim",
    commit = "v2.1.0",
    dependencies = {
      "mason-org/mason.nvim",
      "ibhagwan/fzf-lua",
      "neovim/nvim-lspconfig",
      "nvim-cmp",
    },
    config = function()
      -- Seems to be required
      require("mason-lspconfig").setup({
        automatic_enable = true
      })
    end
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
  {
    "github/copilot.vim",
    commit = "f3d66c148aa60ad04c0a21d3e0a776459de09eb2",
  },
  {
    "mfussenegger/nvim-lint",
    commit = "6e9dd545a1af204c4022a8fcd99727ea41ffdcc8",
    config = function ()
      require("lint").linters_by_ft = {
        typescript = {"eslint_d"},
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()

          require("lint").try_lint()
        end,
      })
    end
  },
}
