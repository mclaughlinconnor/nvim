-- pretty sure I'm woefully underutilising this plugin
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 0,
    ignore_whitespace = false,
  },
})

vim.g.lazygit_floating_window_scaling_factor = 0.95

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "gh", "<cmd> wall | LazyGit <CR>", bufopts)

require("diffview").setup({
  enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
  view = {
    -- Configure the layout and behavior of different types of views.
    -- Available layouts:
    --  'diff1_plain'
    --    |'diff2_horizontal'
    --    |'diff2_vertical'
    --    |'diff3_horizontal'
    --    |'diff3_vertical'
    --    |'diff3_mixed'
    --    |'diff4_mixed'
    -- For more info, see |diffview-config-view.x.layout|.
    merge_tool = {
      -- Config for conflicted files in diff views during a merge or rebase.
      layout = "diff3_mixed",
      disable_diagnostics = false, -- Temporarily disable diagnostics for conflict buffers while in the view.
    },
  },
})
