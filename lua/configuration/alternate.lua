-- TODO: this extension is completely unnecessary --- just write your own code.
-- My own code could have different keymaps to go to different files instead of just one switch

return {
  { "AndrewRadev/switch.vim", commit = "68d269301181835788dcdcb6d5bca337fb954395" },
  {
    "ton/vim-alternate",
    commit = "57a6d2797b3bec39f5c075104082b0c0835535ed",
    init = function()
      vim.g.AlternateExtensionMappings = {
        { [".ts"] = ".pug", [".pug"] = ".ts" },
      }
    end,
    keys = {
      {
        "<leader>ta",
        "<cmd>Alternate<cr>",
        desc = "Switch to alternate file",
      },
    },
  },
}
