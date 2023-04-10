vim.g.nord_contrast = true
vim.g.nord_borders = true
vim.g.nord_italic = true

vim.cmd([[colorscheme nord]])

vim.opt.termguicolors = true

require("indent_blankline").setup({
  use_treesitter = true,
  show_current_context = true,
  show_current_context_start = false,
  context_patterns = {
    "class",
    "^func",
    "method",
    "^if",
    "while",
    "for",
    "with",
    "try",
    "except",
    "arguments",
    "argument_list",
    "object",
    "dictionary",
    "element",
    "table",
    "tuple",
    "do_block",
    "tag", -- default with `tag` added
  },
})
