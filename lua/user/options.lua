local options = {
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  ignorecase = true,                       -- ignore case in search
  smartcase = true,                        -- smart case in search
  mouse = "a",                             -- enable mouse everywhere
  pumheight = 10,                          -- pop up menu height, is unlimited by default
  smartindent = true,                      -- make indenting smarter again
  autoindent = true,                       -- auto indent
  splitbelow = true,                       -- split down
  splitright = true,                       -- split to right
  undolevels = 10000,                      -- big undo
  undofile = true,                         -- store undo in a file
  history = 10000,                         -- big undo
  updatetime = 300,                        -- faster completion (4000ms default)
  expandtab = true,                        -- tabs -> spaces
  shiftwidth = 2,                          -- two spaces for each indent
  tabstop = 2,                             -- insert 2 spaces for a tab
  cursorline = true,                       -- highlight current line
  number = true,                           -- numbered lines
  relativenumber = true,                   -- relative numbered lines
  signcolumn = "yes",                      -- always show the sign column. flickers otherwise
  wrap = false,                            -- show big lines as big lines
  scrolloff = 8,                           -- always show 8 charcters to bottom
  sidescrolloff = 8,                       -- always show 8 characters to side of cursor
  laststatus = 3,                          -- Global statusline
  lazyredraw = true,                       -- Don't redraw when executing macros
  magic = true,                            -- Make vim regex more regex-y
  autoread = true,                         -- re-read files if they are changed
  termguicolors = true,                    -- use full colour
}

vim.opt.shortmess:append("c")         -- don't need extra verbose autocomplete
vim.cmd("set whichwrap+=<,>,[,],h,l") -- movements can wrap over lines
vim.cmd("set iskeyword+=-")           -- make - part of word
vim.g.mapleader = ","

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd([[
augroup highlight_yank
autocmd!
au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=200})
augroup END
]])

local opts = { noremap = true, silent = true }

local typeScriptIndentOnPaste = vim.api.nvim_create_augroup("TypeScriptIndentOnPaste", {})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "p", "p`[v`]=", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "P", "P`[v`]=", opts)
  end,
  group = typeScriptIndentOnPaste,
  pattern = "*.ts",
})

vim.keymap.set("n", "<esc>", "<cmd>noh<cr>", opts)

vim.keymap.set("n", "n", "nzz", opts)
vim.keymap.set("n", "N", "Nzz", opts)
vim.keymap.set("n", "*", "*zz", opts)
vim.keymap.set("n", "#", "#zz", opts)
vim.keymap.set("n", "*", "*zz", opts)
vim.keymap.set("n", "#", "#zz", opts)

vim.keymap.set("v", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("v", "<C-u>", "<C-u>zz", opts)

vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

vim.api.nvim_create_user_command("GenId", function()
  vim.api.nvim_command("silent write")
  vim.cmd(
    [[silent !awk -i inplace '/---/{"xxd -l 12 -p /dev/urandom" | getline uuid; close("xxd -l 12 -p /dev/urandom"); gsub(/---/, uuid)};{print}' %]]
  )
end, {})

vim.keymap.set("n", "<leader>vg", "<cmd>GenId<cr>", opts)

vim.keymap.set("n", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>p", '"+p', opts)

vim.keymap.set("v", "<leader>p", '"+p', opts)
vim.keymap.set("v", "<leader>p", '"+p', opts)

vim.keymap.set("n", "<leader>co", '<cmd>copen<cr>', opts)
vim.keymap.set("n", "<leader>cc", '<cmd>cclose<cr>', opts)

vim.keymap.set("n", "<leader>cn", '<cmd>cnext<cr>', opts)
vim.keymap.set("n", "<leader>cp", '<cmd>cprevious<cr>', opts)
