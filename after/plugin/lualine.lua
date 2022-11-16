require('lualine').setup({
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics', 'quickfix'},
    lualine_c = {'filename'},
    lualine_x = {'lsp_progress'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
})