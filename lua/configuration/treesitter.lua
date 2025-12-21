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
    commit = "8cdffc6d334731ce3703b6d870a5a34fd878208a", -- 0.10
    config = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers')
          local parser_config = require("nvim-treesitter.parsers")

          parser_config.pug = {
            install_info = {
              url = "https://github.com/mclaughlinconnor/tree-sitter-pug",
              files = { "src/parser.c", "src/scanner.c" },
              revision = "betterindents",
            },
            filetype = "pug",
            maintainers = { "@mclaughlinconnor" },
            queries = "queries/pug",
            tier = 1,
          }

          parser_config.angular_content = {
            install_info = {
              url = "github.com/mclaughlinconnor/tree-sitter-angular-content",
              files = { "src/parser.c", "src/scanner.c" },
              revision = "master",
            },
            maintainers = { "@mclaughlinconnor" },
            queries = "queries/angular_content",
            tier = 1,
          }

          parser_config.angular_expr = {
            install_info = {
              url = "https://github.com/mclaughlinconnor/tree-sitter-angular",
              files = { "src/parser.c" },
              revision = "main",
            },
            maintainers = { "@mclaughlinconnor" },
            queries = "queries/angular_expr",
            tier = 1,
          }

          parser_config.haxe = {
            install_info = {
              url = "https://github.com/vantreeseba/tree-sitter-haxe",
              files = { "src/parser.c" },
              revision = "main",
            },
            filetype = "haxe",
            queries = "queries/haxe",
            tier = 1,
          }
        end})

        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'typescript', 'javascript', 'pug', 'yaml', 'json', 'ts', 'js', 'yml' },
          callback = function()
            -- syntax highlighting, provided by Neovim
            vim.treesitter.start()
          end,
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'typescript', 'javascript', 'yaml', 'json', 'ts', 'js', 'yml' },
          callback = function()
            -- folds, provided by Neovim
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end,
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'typescript', 'javascript', 'yaml', 'json', 'ts', 'js', 'yml' },
          callback = function()
            -- indentation, provided by nvim-treesitter
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })

        require'nvim-treesitter'.setup({
          ensure_installed = "all", -- one of "all" or a list of languages
          -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
          ignore_install = { "phpdoc", "ipkg", "gdshader", "rnoweb" }, -- List of parsers to ignore installing
          highlight = {
            enable = true,
            disable = function(lang) -- Disable in large C++ buffers
              -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
              if lang == "latex" or lang == "css" or lang == "haxe" then
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
          indent = { enable = true, disable = { "css" } },
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
  },
  { "nvim-treesitter/nvim-treesitter-textobjects", commit = "b54cec389e98c5b0babbe618773acec927437cab", dependencies = { "nvim-treesitter/nvim-treesitter" } },
  {
    "ThePrimeagen/refactoring.nvim",
    commit = "74b608dfee827c2372250519d433cc21cb083407",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
    keys = {
      -- Select refactor
      {
        "<leader>rr",
        function()
          require("refactoring").select_refactor()
        end,
      },
      {
        "<leader>rr",
        function()
          require("refactoring").select_refactor()
        end,
        mode = "x",
      },

      -- Extract function supports only visual mode
      {
        "<leader>re",
        function()
          require("refactoring").refactor("Extract Function")
        end,
        mode = "x",
      },
      {
        "<leader>rf",
        function()
          require("refactoring").refactor("Extract Function To File")
        end,
        mode = "x",
      },

      -- Extract variable supports only visual mode
      {
        "<leader>rv",
        function()
          require("refactoring").refactor("Extract Variable")
        end,
        mode = "x",
      },

      -- Inline func supports only normal
      {
        "<leader>rI",
        function()
          require("refactoring").refactor("Inline Function")
        end,
      },

      -- Inline var supports both normal and visual mode
      {
        "<leader>ri",
        function()
          require("refactoring").refactor("Inline Variable")
        end,
      },
      {
        "<leader>ri",
        function()
          require("refactoring").refactor("Inline Variable")
        end,
        mode = "x",
      },

      -- Extract block supports only normal mode
      {
        "<leader>rb",
        function()
          require("refactoring").refactor("Extract Block")
        end,
      },
      {
        "<leader>rbf",
        function()
          require("refactoring").refactor("Extract Block To File")
        end,
      },
    },
  },
}

-- local bigFile = vim.api.nvim_create_augroup("BigFile", {})
-- vim.api.nvim_create_autocmd({ "BufReadPre","FileReadPre" }, {
--   callback = function()
--     if vim.fn.getfsize(vim.fn.expand("%")) > 512 * 1024 then end
--   end,
--   group = bigFile,
-- })
