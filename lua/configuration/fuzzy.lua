local project_files = function(default_text)
  local opts = { search = default_text }
  require("fzf-lua").files(opts)
end

return {
  {
    "ibhagwan/fzf-lua",
    commit = "a1a2d0f42eaec400cc6918a8e898fc1f9c4dbc5f",
    keys = {
      { "<leader>b", function() require("fzf-lua").buffers() end },
      { "<leader>B", function() require("fzf-lua").oldfiles() end },
      { "<leader>f", project_files },
      {
        "<leader>F",
        function()
          project_files(vim.fn.expand("<cword>"))
        end,
      },
      { "<leader>tj", function() require("fzf-lua").resume() end },
      { "<leader>g", function() require("fzf-lua").live_grep_native() end },
      {
        "<leader>G",
        function()
          require("fzf-lua").live_grep_native({ search = vim.fn.expand("<cword>") })
        end,
      },
      { "<leader>tg", function() require("fzf-lua").lines() end },
      { "<leader>tt", function() require("fzf-lua").tags() end },
      {
        "<leader>tT",
        function()
          require("fzf-lua").tags({ search = vim.fn.expand("<cword>") })
        end,
      },
      { "<leader>tc", function() require("fzf-lua").btags() end },
      { "<leader>tql", function() require("fzf-lua").quickfix() end },
      { "<leader>tqs", function() require("fzf-lua").quickfix_stack() end },
      { "<leader>ts", function() require("fzf-lua").spell_suggest() end },
      { "<leader>th", function() require("fzf-lua").help_tags() end },
      { "<leader>loc", function() require("fzf-lua").git_commits() end },
      { "<leader>lod", function() require("fzf-lua").git_bcommits() end },
      { "<leader>lob", function() require("fzf-lua").git_branches() end },
      { "<leader>lot", function() require("fzf-lua").git_stash() end },
      { "<leader>dg", function() require("fzf-lua").diagnostics_workspace() end },
      { "<leader>lii", function() require("fzf-lua").lsp_incoming_calls() end },
      { "<leader>lio", function() require("fzf-lua").lsp_outgoing_calls() end },
      { "<leader>lyl", function() require("fzf-lua").lsp_finder() end },
      {
        "<M-p>",
        function()
          vim.cmd("stopinsert")
        end,
        mode = "i",
      },
      { "<leader>tp", function() require("user.pickers.translations")() end },
    },
    opts = function()
      local actions = require("fzf-lua.actions")

      return {
        "default",
        winopts = {
          preview = {
            delay = 50,
          },
          height = 0.95,
          width = 0.97,
          row = 0.2,
          on_create = function()
            vim.keymap.set("t", "<M-S-j>", function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-Down>", true, false, true), "n", true)
            end, { nowait = true, buffer = true })
            vim.keymap.set("t", "<M-S-k>", function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-Up>", true, false, true), "n", true)
            end, { nowait = true, buffer = true })

            vim.keymap.set("t", "<M-p>", function()
              vim.cmd("stopinsert")
            end, { nowait = true, buffer = true })
          end,
        },
        keymap = {
          builtin = {
            ["<M-h>"] = "toggle-help",
            ["<M-z>"] = "toggle-fullscreen",

            ["<M-'>"] = "toggle-preview-wrap",
            ["<M-;>"] = "toggle-preview",

            ["<C-j>"] = "preview-page-down",
            ["<C-k>"] = "preview-page-up",
            ["<C-l>"] = "preview-page-reset",
          },
          fzf = {
            ["ctrl-z"] = "abort",
            ["ctrl-u"] = "unix-line-discard",

            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "toggle-all",

            ["alt-'"] = "toggle-preview-wrap",
            ["alt-;"] = "toggle-preview",

            ["ctrl-j"] = "preview-half-page-down",
            ["ctrl-k"] = "preview-half-page-up",

            ["alt-down"] = "half-page-down",
            ["alt-up"] = "half-page-up",

            ["alt-j"] = "down",
            ["alt-k"] = "up",

            ["alt-i"] = "next-history",
            ["alt-u"] = "previous-history",
          },
        },
        actions = {
          files = {
            -- providers that inherit these require("fzf-lua.actions"):
            --   files, git_files, git_status, grep, lsp
            --   oldfiles, quickfix, loclist, tags, btags
            --   args
            ["default"] = actions.file_edit_or_qf,
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-t"] = actions.file_tabedit,
            ["ctrl-q"] = actions.file_sel_to_qf,
            ["ctrl-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            -- providers that inherit these require("fzf-lua.actions"):
            --   buffers, tabs, lines, blines
            ["default"] = actions.buf_edit,
            ["ctrl-s"] = actions.buf_split,
            ["ctrl-v"] = actions.buf_vsplit,
            ["ctrl-t"] = actions.buf_tabedit,
          },
        },

        global_git_icons = false,
        global_file_icons = false,

        manpages = { previewer = "man_native" },
        helptags = { previewer = "help_native" },
        files = {
          fzf_opts = {
            ["--ansi"] = false,
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
          },
        },
        grep = {
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
          },
        },
      }
    end,
  },
}
