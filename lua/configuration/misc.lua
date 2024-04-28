return {
  { "stevearc/dressing.nvim", commit = "8b7ae53d7f04f33be3439a441db8071c96092d19" },
  { "nvim-lua/plenary.nvim", commit = "55d9fe89e33efd26f532ef20223e5f9430c8b0c0" },
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
}
