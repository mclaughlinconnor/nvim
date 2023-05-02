-- Setup nvim-cmp.
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

cmp.setup({
  enabled = function()
    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
    return buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
  end,
  preselect = cmp.PreselectMode.None,
  completion = {
    keyword_length = 0,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = {
      cmp.ItemField.Abbr,
      cmp.ItemField.Kind,
      cmp.ItemField.Menu,
    },
    format = function(entry, vim_item)
      -- Source
      vim_item.menu = ({
        buffer = "[B]",
        calc = "[C]",
        cmdline_history = "[CH]",
        cmp_git = "[CG]",
        luasnip = "[LS]",
        luasnip_choice = "[LSC]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[L]",
        path = "[P]",
        treesitter = "[TS]",
        spell = "[S]",
      })[entry.source.name]
      return vim_item
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<M-;>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<M-j>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<M-k>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  }),
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "luasnip_choice" },
    { name = "calc" },
    { name = "path" },
    { name = "nvim_lsp" },
  }, {
    { name = "treesitter" },
    {
      name = "spell",
      option = {
        enable_in_context = function()
          return require("cmp.config.context").in_treesitter_capture("spell")
        end,
      },
    },
    { name = "buffer" },
  }),
})

cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = "path" },
    { name = "buffer" },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline({
    ["<M-j>"] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ["<M-k>"] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
  }),
  sources = cmp.config.sources({ { name = "cmdline_history" } }, { { name = "buffer" } }),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline({
    ["<M-j>"] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ["<M-k>"] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
  }),
  sources = cmp.config.sources({ { name = "cmdline" } }, { { name = "path" } }),
})

local jsonDisableTS = vim.api.nvim_create_augroup("JsonDisableTS", {})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    local sources = cmp.get_config().sources
    for i = #sources, 1, -1 do
      if sources[i].name == "treesitter" then
        table.remove(sources, i)
        break
      end
    end
    cmp.setup.buffer({ sources = sources })
  end,
  group = jsonDisableTS,
  pattern = "*.json",
})
