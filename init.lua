require("impatient")

vim.filetype.add({
  extension = {
    hx = "haxe",
  },
})

require("user.options")
require("user.plugins")
