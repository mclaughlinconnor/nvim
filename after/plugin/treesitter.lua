local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.pug = {
  install_info = {
    url = "github.com/mclaughlinconnor/tree-sitter-pug",
    files = { "src/parser.c", "src/scanner.cc" },
    revision = "attrs",
  },
  filetype = "pug",
  maintainers = { "@mclaughlinconnor" },
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
    disable = function(lang, bufnr) -- Disable in large C++ buffers
      -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
      if lang == "latex" or lang == "css" or lang == "yaml" then
        return true
      end

      -- Disable for large files
      return vim.fn.getfsize(vim.fn.expand("%")) > 10 * 1024 -- 10 kilobytes
    end,
  },
  autopairs = {
    enable = true,
  },
  indent = { enable = true, disable = { "python", "css" } },
  rainbow = {
    enable = true,
    disable = {},
    extended_mode = true,
    max_file_lines = nil,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
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

require("iswap").setup({
  move_cursor = true,
  autoswap = true,
  flash_style = "simultaneous",
})

vim.keymap.set("n", "<leader>a", "<CMD>:ISwapNodeWithRight<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>A", "<CMD>:ISwapNodeWithLeft<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sa", "<CMD>:ISwapNodeWith<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sA", "<CMD>:ISwap<CR>", { noremap = true, silent = true })

-- local bigFile = vim.api.nvim_create_augroup("BigFile", {})
-- vim.api.nvim_create_autocmd({ "BufReadPre","FileReadPre" }, {
--   callback = function()
--     if vim.fn.getfsize(vim.fn.expand("%")) > 512 * 1024 then end
--   end,
--   group = bigFile,
-- })
