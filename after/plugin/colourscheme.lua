vim.cmd.colorscheme("nord")

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

vim.g.indent_blankline_enabled = false

local setColour = function(colour)
  vim.cmd.colorscheme(colour)
  -- Same as default, except with `Cursor` added in to change the highlight group
  vim.cmd([[
    set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
  ]])
end

vim.api.nvim_create_user_command("FlashBang", function()
  setColour("tokyonight-day")
  -- Makes the diff colour **much** better
  vim.cmd([[highlight DiffAdd guibg=#a4cf69]])
  vim.cmd([[highlight DiffChange guibg=#63c1e6]])
  vim.cmd([[highlight DiffDelete guibg=#d74f56]])
end, {})

vim.api.nvim_create_user_command("LightsOut", function()
  setColour("nord")
end, {})
