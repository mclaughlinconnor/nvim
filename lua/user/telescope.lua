local actions = require('telescope.actions')
local actions_layout = require('telescope.actions.layout')
local builtin = require('telescope.builtin')
local telescope = require('telescope')

telescope.setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    path_display = "smart",
    mappings = {
      n = {
        ["<M-j>"] = actions.move_selection_next,
        ["<M-k>"] = actions.move_selection_previous,
        ["<C-k>"] = actions.preview_scrolling_up,
        ["<C-j>"] = actions.preview_scrolling_down,
        ["<M-/>"] = actions.which_key,
        ["<M-o>"] = actions.cycle_history_next,
        ["<M-i>"] = actions.cycle_history_prev,
        ["q"] = actions.close,
        ["p"] = actions.close,
        ["<M-;>"] = actions_layout.toggle_preview
      },
      i = {
        ["<M-j>"] = actions.move_selection_next,
        ["<M-k>"] = actions.move_selection_previous,
        ["<C-k>"] = actions.preview_scrolling_up,
        ["<C-j>"] = actions.preview_scrolling_down,
        ["<M-/>"] = actions.which_key,
        ["<M-i>"] = actions.cycle_history_next,
        ["<M-u>"] = actions.cycle_history_prev,
        ["<Esc>"] = actions.close,
        ["<M-;>"] = actions_layout.toggle_preview,
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
    },
    git_files = {
      show_untracked = true,
    }
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}

telescope.load_extension('fzf')
-- TODO: add nvim-telescope/telescope-symbols.nvim source for work icons

local bufopts = { noremap = true, silent = true }
-- do I want find_files or git_files?
vim.keymap.set('n', 'gla', builtin.oldfiles, bufopts)
vim.keymap.set('n', 'glb', builtin.buffers, bufopts)
vim.keymap.set('n', 'glff', builtin.git_files, bufopts)
vim.keymap.set('n', 'glfg', builtin.find_files, bufopts)
vim.keymap.set('n', 'glg', builtin.live_grep, bufopts)
vim.keymap.set('n', 'glh', builtin.help_tags, bufopts)
vim.keymap.set('n', 'glj', builtin.resume, bufopts)
vim.keymap.set('n', 'glk', builtin.current_buffer_fuzzy_find, bufopts)
vim.keymap.set('n', 'gll', builtin.current_buffer_tags, bufopts)
vim.keymap.set('n', 'glp', builtin.pickers, bufopts)
vim.keymap.set('n', 'glq', builtin.quickfix, bufopts)
vim.keymap.set('n', 'glr', builtin.registers, bufopts)
vim.keymap.set('n', 'gls', builtin.spell_suggest, bufopts)
vim.keymap.set('n', 'glt', builtin.tags, bufopts)

vim.keymap.set('n', 'gloc', builtin.git_commits, bufopts)
vim.keymap.set('n', 'glod', builtin.git_bcommits, bufopts)
vim.keymap.set('n', 'glob', builtin.git_branches, bufopts)
vim.keymap.set('n', 'glos', builtin.git_status, bufopts)
vim.keymap.set('n', 'glot', builtin.git_stash, bufopts)

vim.keymap.set('n', 'gld', builtin.diagnostics, bufopts) -- gives diagnostics for whole workspace
vim.keymap.set('n', 'glii', builtin.lsp_incoming_calls, bufopts) -- no typescript/angular
vim.keymap.set('n', 'glio', builtin.lsp_outgoing_calls, bufopts) -- no typescript/angular
vim.keymap.set('n', 'glyt', builtin.treesitter, bufopts)
vim.keymap.set('n', 'glyl', builtin.lsp_document_symbols, bufopts) -- no typescipt/angular
vim.keymap.set('n', 'glmt', builtin.lsp_type_definitions, bufopts)
vim.keymap.set('n', 'glmd', builtin.lsp_definitions, bufopts)
vim.keymap.set('n', 'glmi', builtin.lsp_implementations, bufopts) -- no typescript/angular

vim.keymap.set('i', '<M-p>', function () vim.cmd('stopinsert') end, bufopts)
