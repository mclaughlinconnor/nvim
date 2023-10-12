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

local noop = function() end
local q = function()
  vim.cmd.unmap("q")
end

require("diffview").setup({
  enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
  use_icons = false,
  keymaps = {
    view = {
      ["q"] = q,
      ["<esc>"] = noop,
    },
    file_panel = {
      ["q"] = q,
      ["<esc>"] = noop,
    },
  },
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
      layout = "diff3_horizontal",
      disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
    },
  },
})

vim.keymap.set("n", "<leader>do", "<cmd> DiffviewOpen <CR>", bufopts)
vim.keymap.set("n", "<leader>dO", "<cmd> DiffviewClose <CR>", bufopts)

require("neogit").setup()

vim.keymap.set("n", "gH", "<cmd> wall | LazyGit <CR>", bufopts)
vim.keymap.set("n", "gh", "<cmd> Neogit <CR>", bufopts)

vim.opt.diffopt:append({ "indent-heuristic", "algorithm:histogram", "linematch:60" })

local lineNumbers = vim.api.nvim_create_augroup("lineNumbers", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function()
    vim.o.number = true
    vim.o.relativenumber = true
  end,
  group = lineNumbers,
  pattern = { "NeogitStatus", "NeogitRebaseTodo", "NeogitCommitSelectView", "NeogitCommitMessage" },
})

local toggle_diff = function()
  if vim.api.nvim_win_get_option(0, "diff") then
    vim.cmd.diffoff()
  else
    vim.cmd.diffthis()
  end
end

vim.keymap.set("n", "<leader>dt", toggle_diff, bufopts)
