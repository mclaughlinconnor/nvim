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

vim.g.lazygit_floating_window_scaling_factor = 1

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "gh", "<cmd> wall | LazyGit <CR>", bufopts)

require("diffview").setup({
  enhanced_diff_hl = false, -- See |diffview-config-enhanced_diff_hl|
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
      layout = "diff4_mixed",
      disable_diagnostics = false, -- Temporarily disable diagnostics for conflict buffers while in the view.
    },
  },
})

vim.keymap.set("n", "<leader>do", "<cmd> DiffviewOpen <CR>", bufopts)
vim.keymap.set("n", "<leader>dO", "<cmd> DiffviewClose <CR>", bufopts)

-- Weird darker theme, "inline" popups
-- buffer_history_preview
-- buffer_blame_preview
-- require("vgit").setup()

-- I just don't like this one
-- the docs are awful which, for such a complex plugin, is unacceptable.
-- Try vimagit
require("neogit").setup()

vim.o.diffopt = "internal,filler,closeoff,icase,iblank,iwhite,algorithm:histogram,indent-heuristic,linematch:50"
