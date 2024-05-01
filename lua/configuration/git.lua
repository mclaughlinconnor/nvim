local toggle_diff = function()
  if vim.o.diff then
    vim.cmd.diffoff()
  else
    vim.cmd.diffthis()
  end
end

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>dt", toggle_diff, bufopts)

local noop = function() end
local q = function()
  vim.cmd.unmap("q")
end

return {
  {
    "harrisoncramer/gitlab.nvim",
    commit = "c0c67486d17d4f73f62b50c13c77aaed2e9f17f0",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "mclaughlinconnor/diffview.nvim",
      "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
      "nvim-tree/nvim-web-devicons" -- Recommended but not required. Icons in discussion tree.
    },
    enabled = true,
    build = function () require("gitlab.server").build(true) end, -- Builds the Go binary
    config = function()
      require("gitlab").setup(
        {
          config_path = vim.fn.expand("$HOME"),
        }
      )
    end,
  },
  {
    -- pretty sure I'm woefully underutilising this plugin
    "lewis6991/gitsigns.nvim",
    commit = "6ef8c54fb526bf3a0bc4efb0b2fe8e6d9a7daed2",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 0,
        ignore_whitespace = false,
      },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    commit = "de35012036d43bca03628d40d083f7c02a4cda3f",
    init = function()
      vim.g.lazygit_floating_window_scaling_factor = 1
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    commit = "de35012036d43bca03628d40d083f7c02a4cda3f",

    keys = {
      {
        "gH",
        function()
          vim.cmd.wall()
          vim.cmd.LazyGit()
        end,
      },
    },
  },
  {
    "NeogitOrg/neogit",
    commit = "df527d152d34214a3a24a577bf7ef1f121e8add2",
    keys = {
      {
        "gh",
        function()
          vim.cmd.Neogit()
        end,
      },
    },
    config = function()
      require("neogit").setup({})

      local lineNumbers = vim.api.nvim_create_augroup("lineNumbers", {})
      vim.api.nvim_create_autocmd({ "FileType" }, {
        callback = function()
          vim.o.number = true
          vim.o.relativenumber = true
        end,
        group = lineNumbers,
        pattern = { "NeogitStatus", "NeogitRebaseTodo", "NeogitCommitSelectView", "NeogitCommitMessage" },
      })
    end,
    requires = "nvim-lua/plenary.nvim",
  },
  {
    "mclaughlinconnor/diffview.nvim",
    commit = "44a5b386b21a6704d28a027ca819a837b1968df8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "camspiers/luarocks",
    },
    keys = {
      {
        "<leader>do",
        function()
          vim.cmd.DiffviewOpen()
        end,
      },
      {
        "<leader>dO",
        function()
          vim.cmd.Close()
        end,
      },
      {
        "<leader>rg",
        function()
          vim.cmd("DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges --imply-local")
        end,
      },
      {
        "<leader>rc",
        function()
          vim.cmd("DiffviewFileHistory %")
        end,
      },
    },
    opts = {
      enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
      use_icons = false,
      default_args = {
        DiffviewOpen = { "--imply-local" },
      },
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
    },
  },
}
