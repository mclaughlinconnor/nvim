return {
  { "arkav/lualine-lsp-progress", commit = "56842d097245a08d77912edf5f2a69ba29f275d7" },
  {
    "nvim-lualine/lualine.nvim",
    commit = "b8c23159c0161f4b89196f74ee3a6d02cdc3a955",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics", "quickfix" },
        lualine_c = {
          { "filename", path = 1 },
          "call gutentags#statusline()",
        },
        lualine_x = { "lsp_progress" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
