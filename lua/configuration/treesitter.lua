return {
  {
    "mizlan/iswap.nvim",
    commit = "6b77e8a2235aebbc6d2df150d0c780200f0cefa2",
    keys = {
      { "<leader>a", vim.cmd.ISwapNodeWithRight },
      { "<leader>A", vim.cmd.ISwapNodeWithLeft },
      { "<leader>sa", vim.cmd.ISwapNodeWith },
      { "<leader>sA", vim.cmd.ISwap },
    },
    opts = {
      move_cursor = true,
      autoswap = true,
      flash_style = "simultaneous",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    commit = "80a16deb5146a3eb4648effccda1ab9f45e43e76",
    config = function()
      local configs = require("nvim-treesitter.configs")
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.pug = {
        install_info = {
          url = "https://github.com/mclaughlinconnor/tree-sitter-pug",
          files = { "src/parser.c", "src/scanner.c" },
          revision = "attrs",
        },
        filetype = "pug",
        maintainers = { "@mclaughlinconnor" },
      }

      parser_config.angular_content = {
        install_info = {
          url = "github.com/mclaughlinconnor/tree-sitter-angular-content",
          files = { "src/parser.c", "src/scanner.c" },
          revision = "master",
        },
        maintainers = { "@mclaughlinconnor" },
      }

      parser_config.angular = {
        install_info = {
          url = "https://github.com/tamusall/tree-sitter-angular",
          files = { "src/parser.c" },
          branch = "main",
        },
        maintainers = { "@tamusall" },
      }

      parser_config.haxe = {
        install_info = {
          url = "https://github.com/vantreeseba/tree-sitter-haxe",
          files = { "src/parser.c" },
          branch = "main",
        },
        filetype = "haxe",
      }

      configs.setup({
        ensure_installed = "all", -- one of "all" or a list of languages
        -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
        ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
        highlight = {
          enable = true,
          disable = function(lang) -- Disable in large C++ buffers
            -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
            if lang == "latex" or lang == "css" or lang == "yaml" then
              return true
            end

            -- Disable for large files
            return false
            -- return vim.fn.getfsize(vim.fn.expand("%")) > 50 * 1024 -- 10 kilobytes
          end,
        },
        autopairs = {
          enable = true,
        },
        indent = { enable = true, disable = { "python", "css" } },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ib"] = "@block.inner",
              ["ab"] = "@block.outer",
              ["ic"] = "@call.inner",
              ["ac"] = "@call.outer",
              ["ao"] = "@comment.outer",
              ["in"] = "@conditional.inner",
              ["an"] = "@conditional.outer",
              ["il"] = "@loop.inner",
              ["al"] = "@loop.outer",
              ["ip"] = "@parameter.inner",
              ["ap"] = "@parameter.outer",
            },
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {},
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding xor succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]p"] = "@parameter.inner",
              ["[A"] = "@call.inner",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]P"] = "@parameter.outer",
              ["]a"] = "@call.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[p"] = "@parameter.inner",
              ["[a"] = "@call.inner",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[P"] = "@parameter.outer",
              ["]A"] = "@call.outer",
            },
          },
          swap = {
            enable = false, -- use ISwap instead
          },
        },
      })
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  },
  { "nvim-treesitter/nvim-treesitter-textobjects", commit = "ec1c5bdb3d87ac971749fa6c7dbc2b14884f1f6a" },
}

-- local bigFile = vim.api.nvim_create_augroup("BigFile", {})
-- vim.api.nvim_create_autocmd({ "BufReadPre","FileReadPre" }, {
--   callback = function()
--     if vim.fn.getfsize(vim.fn.expand("%")) > 512 * 1024 then end
--   end,
--   group = bigFile,
-- })
