-- pretty sure I'm woefully underutilising this plugin
require('gitsigns').setup {
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 0,
    ignore_whitespace = false,
  },
}

vim.g.lazygit_floating_window_scaling_factor = 0.95

local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', 'gh', "<cmd> wall | LazyGit <CR>", bufopts)
