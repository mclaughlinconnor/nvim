return {
  {
    "dmmulroy/tsc.nvim",
    commit = "8c1b4ec6a48d038a79ced8674cb15e7db6dd8ef0",
    opts = {},
  },
  {
    "stevearc/dressing.nvim",
    commit = "8b7ae53d7f04f33be3439a441db8071c96092d19",
    opts = {
      input = {
        insert_only = false,
      },
    },
  },
  { "nvim-lua/plenary.nvim", commit = "857c5ac632080dba10aae49dba902ce3abf91b35" },
  -- ~/.local/share/nvim/lazy/luarocks/.rocks/bin/luarocks install lrexlib-pcre2 PCRE2_DIR="/opt/homebrew/opt/pcre2" PCRE2_INCDIR="/opt/homebrew/opt/pcre2/include"
  {
    "camspiers/luarocks",
    opts = {
      rocks = {
        "luautf8",
        "lrexlib-pcre2",
      },
    },
  },
  { "tpope/vim-abolish", commit = "dcbfe065297d31823561ba787f51056c147aa682" },
  {"tpope/vim-repeat", commit = "65846025c15494983dafe5e3b46c8f88ab2e9635"},
}
