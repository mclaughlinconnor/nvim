local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

local project_files = function(default_text)
  local opts = { search = default_text }
  if fzf.path.is_git_repo() then
    fzf.git_files(opts)
  else
    fzf.files(opts)
  end
end

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>b", fzf.buffers, bufopts)
vim.keymap.set("n", "<leader>B", fzf.oldfiles, bufopts)

vim.keymap.set("n", "<leader>f", project_files, bufopts)
vim.keymap.set("n", "<leader>F", function()
  project_files(vim.fn.expand("<cword>"))
end, bufopts)

vim.keymap.set("n", "<leader>tj", fzf.resume, bufopts)

vim.keymap.set("n", "<leader>g", fzf.live_grep_native, bufopts)
vim.keymap.set("n", "<leader>G", function()
  fzf.live_grep_native({ search = vim.fn.expand("<cword>") })
end, bufopts)
vim.keymap.set("n", "<leader>tg", fzf.lines, bufopts)
vim.keymap.set("n", "<leader>tt", fzf.tags, bufopts)
vim.keymap.set("n", "<leader>tT", function()
  fzf.tags({ search = vim.fn.expand("<cword>") })
end, bufopts)
vim.keymap.set("n", "<leader>tc", fzf.btags, bufopts)

vim.keymap.set("n", "<leader>tql", fzf.quickfix, bufopts)
vim.keymap.set("n", "<leader>tqs", fzf.quickfix_stack, bufopts)
vim.keymap.set("n", "<leader>ts", fzf.spell_suggest, bufopts)

vim.keymap.set("n", "<leader>th", fzf.help_tags, bufopts)

vim.keymap.set("n", "<leader>loc", fzf.git_commits, bufopts)
vim.keymap.set("n", "<leader>lod", fzf.git_bcommits, bufopts)
vim.keymap.set("n", "<leader>lob", fzf.git_branches, bufopts)
vim.keymap.set("n", "<leader>lot", fzf.git_stash, bufopts)

vim.keymap.set("n", "<leader>dg", fzf.diagnostics_workspace, bufopts)

vim.keymap.set("n", "<leader>lii", fzf.lsp_incoming_calls, bufopts) -- no typescript/angular
vim.keymap.set("n", "<leader>lio", fzf.lsp_outgoing_calls, bufopts) -- no typescript/angular
vim.keymap.set("n", "<leader>lyl", fzf.lsp_finder, bufopts) -- no typescipt/angular

vim.keymap.set("i", "<M-p>", function()
  vim.cmd("stopinsert")
end, bufopts)

local translationPicker = function()
  local opts = { path_shorten = true }

  opts.actions = fzf.defaults.actions.files
  opts.previewer = "builtin"
  opts.fn_transform = function(x)
    return fzf.make_entry.file(x, opts)
  end

  fzf.fzf_live(function(query)
    local cmd_string =
      [[rg -i --color never --type yaml "(\w+)(:.*<query>.*)" --no-heading --no-filename --no-line-number --replace '$1' --null | parallel --colsep '\0' rg {} --color never --no-heading --line-number --column -g "\*.pug" ./]]
    return (cmd_string):gsub("<query>", query)
  end, opts)
end

vim.keymap.set("n", "<leader>tp", translationPicker, bufopts)

fzf.setup({
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
      -- providers that inherit these actions:
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
      -- providers that inherit these actions:
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
})
