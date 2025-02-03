vim.bo.textwidth = 120

vim.cmd("setlocal iskeyword+=+") -- make + part of word
vim.cmd("setlocal iskeyword+=-") -- make - part of word
vim.cmd("set colorcolumn=121") -- The column is the wall that may not be touched or crossed

local opts = { noremap = true, silent = true }

vim.api.nvim_buf_set_keymap(0, "n", "p", "p`[v`]=", opts)
vim.api.nvim_buf_set_keymap(0, "n", "P", "P`[v`]=", opts)

vim.api.nvim_buf_set_keymap(0, "v", "p", "p`[v`]=", opts)
vim.api.nvim_buf_set_keymap(0, "v", "P", "P`[v`]=", opts)
