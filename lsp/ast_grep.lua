return {
  cmd = { "sg", "lsp", "--config", vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/misc/ast-grep/sgconfig.yml" },
  root_dir = vim.fn.getcwd(),
  filetypes = { "typescript", "pug" },
  name = "ast_grep"
}
