return {
  {
    "hrsh7th/nvim-cmp",
    commit = "0b751f6beef40fd47375eaf53d3057e0bfa317e4",
    dependencies = {
      { "FelipeLema/cmp-async-path", commit = "d8229a93d7b71f22c66ca35ac9e6c6cd850ec61d" },
      { "L3MON4D3/LuaSnip" }, -- configured elsewhere
      { "delphinus/cmp-ctags", commit = "8d9ddae9ea20c303bdc0888b663c0459b0dc72c2" },
      { "dmitmel/cmp-cmdline-history", commit = "003573b72d4635ce636234a826fa8c4ba2895ffe" },
      { "doxnit/cmp-luasnip-choice", commit = "97a367851bc17984b56164b5427a53919aed873a" },
      { "f3fora/cmp-spell", commit = "32a0867efa59b43edbb2db67b0871cfad90c9b66" },
      { "hrsh7th/cmp-buffer", commit = "3022dbc9166796b644a841a02de8dd1cc1d311fa" },
      { "hrsh7th/cmp-calc", commit = "ce91d14d2e7a8b3f6ad86d85e34d41c1ae6268d9" },
      { "hrsh7th/cmp-cmdline", commit = "8ee981b4a91f536f52add291594e89fb6645e451" },
      { "hrsh7th/cmp-nvim-lsp", commit = "44b16d11215dce86f253ce0c30949813c0a90765" },
      { "hrsh7th/cmp-omni", commit = "4ef610bbd85a5ee4e97e09450c0daecbdc60de86" },
      { "https://codeberg.org/FelipeLema/cmp-async-path", commit = "91ff86cd9c29299a64f968ebb45846c485725f23" },
      { "ray-x/cmp-treesitter", commit = "b8bc760dfcc624edd5454f0982b63786a822eed9" },
      { "rcarriga/cmp-dap", commit = "d16f14a210cd28988b97ca8339d504533b7e09a4" },
      { "saadparwaiz1/cmp_luasnip", commit = "05a9ab28b53f71d1aece421ef32fee2cb857a843" },
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      cmp.setup({
        enabled = function()
          local buftype = vim.api.nvim_get_option_value("buftype", {})
          return buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
        end,
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
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
              ctags = "[CT]",
              luasnip = "[S]",
              luasnip_choice = "[SC]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[L]",
              omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
              path = "[P]",
              treesitter = "[TS]",
              spell = "[SP]",
            })[entry.source.name]
            return vim_item
          end,
        },
        sorting = {
          comparators = {
            function(...)
              return require("cmp_buffer"):compare_locality(...)
            end,
          },
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<M-a>"] = function() cmp.complete({ config = { sources = { { name = "routes" } } } }) end,
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
          { name = "nvim_lsp" },
        }, {
          { name = "calc" },
          { name = "async_path" },
          { name = "ctags" },
          { name = "treesitter" },
          {
            name = "spell",
            option = {
              enable_in_context = function()
                return require("cmp.config.context").in_treesitter_capture("spell")
              end,
            },
          },
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
        }),
      })

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" },
        }, {
          { name = "path" },
          { name = "buffer" },
        }),
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
    end,
  },
}
