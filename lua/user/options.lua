local options = {
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  ignorecase = true, -- ignore case in search
  smartcase = true, -- smart case in search
  mouse = "a", -- enable mouse everywhere
  pumheight = 10, -- pop up menu height, is unlimited by default
  -- Do I need a tabline?
  -- showtabline = 2, -- always show tabs
  smartindent = true, -- make indenting smarter again
  autoindent = true, -- auto indent
  splitbelow = true, -- split down
  splitright = true,-- split to right
  undolevels = 10000, -- big undo
  history = 10000, -- big undo
  updatetime = 300, -- faster completion (4000ms default)
  expandtab = true, -- tabs -> spaces
  shiftwidth = 2, -- two spaces for each indent
  tabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight current line
  number = true, -- numbered lines
  relativenumber = true, -- relative numbered lines
  signcolumn = "yes", -- always show the sign column. flickers otherwise
  wrap = false, -- show big lines as big lines
  scrolloff = 8, -- always show 8 charcters to bottom
  sidescrolloff = 8, -- always show 8 characters to side of cursor
  laststatus = 3, -- Global statusline
  lazyredraw = true, -- Don't redraw when executing macros
  magic = true, -- Make vim regex more regex-y
  autoread = true, -- re-read files if they are changed
}

vim.opt.shortmess:append "c" -- don't need extra verbose autocomplete
vim.cmd "set whichwrap+=<,>,[,],h,l" -- movements can wrap over lines

for k, v in pairs(options) do
  vim.opt[k] = v
end
