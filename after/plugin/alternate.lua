-- TODO: this extension is completely unnecessary --- just write your own code.
-- My own code could have different keymaps to go to different files instead of just one switch

vim.g.AlternateExtensionMappings = {
  { [".ts"] = ".pug", [".pug"] = ".ts" },
}

vim.keymap.set("n", "<leader>ta", "<cmd>Alternate<cr>", { noremap = true, silent = true })
