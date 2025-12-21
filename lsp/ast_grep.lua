return {
  cmd = { "sg", "lsp", "--config", vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/misc/ast-grep/sgconfig.yml" },
  filetypes = { "typescript", "pug" },
}
