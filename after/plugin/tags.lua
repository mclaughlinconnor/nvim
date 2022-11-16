vim.g.gutentags_add_default_project_roots = 0
vim.g.gutentags_project_root = { "package.json", ".git" }

vim.g.gutentags_exclude_filetypes = { "html" }

vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/vim/ctags/")

vim.api.nvim_create_user_command("GutentagsClearCache", 'call system("rm " . g:gutentags_cache_dir . "/*")', {})

vim.g.gutentags_generate_on_new = 1
vim.g.gutentags_generate_on_missing = 1
vim.g.gutentags_generate_on_write = 1
vim.g.gutentags_generate_on_empty_buffer = 0

vim.g.gutentags_ctags_extra_args = {
  "--tag-relative=yes",
  "--fields=+aiklmnS",
  "--options=" .. vim.fn.expand("<sfile>:h") .. "/../../options.ctags",
}

vim.g.gutentags_ctags_exclude = {
  "node_modules",
  ".tmp",
  "*-lock.json",
  "dist",
  ".idea",
  ".vscode",
  "angular.json",
  "tslint*.json",
  "tsconfig*.json",
  "eslint*json",
  "sails.io.js",
  ".angular",
  ".src",
  ".nyc_output",
  ".wp-babel-cache",
  ".gitlab",
  "rendered_css.json",
}