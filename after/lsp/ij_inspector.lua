return {
  cmd = vim.lsp.rpc.connect('127.0.0.1', 2517),
  root_dir = vim.fn.getcwd(),
  filetypes = { "typescript", "javascript", "html", "scss", "sass", "css", "less", "pug", "java", "kotlin" },
  name = "ij_inspector",
}
