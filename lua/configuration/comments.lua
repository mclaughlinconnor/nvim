return {
  {
    "numToStr/Comment.nvim",
    commit = "0236521ea582747b58869cb72f70ccfa967d2e89",
    config = function()
      require("Comment").setup()

      local ft = require("Comment.ft")
      ft.set("pug", "//- %s")
      ft.set("haxe", "// %s")

      local origCalculate = ft.calculate
      ft.calculate = function(ctx)
        if vim.bo.filetype == "htmldjango.jinja" then
          return ft.get(vim.bo.filetype, ctx.ctype)
        end

        return origCalculate(ctx)
      end

      ft.set('htmldjango', {'{# %s #}'})
      ft.set('jinja', {'{# %s #}'})
      ft.set('htmldjango.jinja', {'{# %s #}'})
    end,
  },
}
