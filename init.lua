-- Current nvim HEAD: 17f3a3ae31d91944a5a4e56aa743745cff7fdf07

vim.loader.enable()

vim.filetype.add({
  extension = {
    hx = "haxe",
  },
})

require("user.options")
require("user.plugins")
