return {
  {
    "numToStr/Comment.nvim",
    commit = "0236521ea582747b58869cb72f70ccfa967d2e89",
    config = function()
      require("Comment").setup()

      local ft = require("Comment.ft")
      ft.set("pug", "//- %s")
      ft.set("haxe", "// %s")
    end,
  },
}
