local bufopts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>tr", "<cmd>UndotreeToggle<cr>", bufopts)
