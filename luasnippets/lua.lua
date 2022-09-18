return {
  s("use", fmta([[use({ "<>", commit = "<>" })]], { i(1), i(2) })),
  s(
    "key",
    fmta(
      [[vim.keymap.set('<>', '<>', <>, { noremap = true, silent = true })]],
      { c(1, {
        t("n"),
        t("i"),
        t("v"),
        i(nil),
      }), i(2), i(3) }
    )
  ),
}, {}
