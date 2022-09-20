vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  sync_root_with_cwd = true,
  view = {
    adaptive_size = true,
  },
  renderer = {
    highlight_opened_files = "name",
    indent_markers = {
      enable = true,
    },
  },
})

vim.keymap.set("n", "<leader>r", "<cmd>:NvimTreeToggle<CR>", { noremap = true, silent = true })
