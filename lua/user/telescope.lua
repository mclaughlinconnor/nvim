local actions = require('telescope.actions')
local actions_layout = require('telescope.actions.layout')
local builtin = require('telescope.builtin')
local telescope = require('telescope')

telescope.setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    path_display = {"smart"},
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
    },
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
      mappings = {
        n = {
          ["<M-d>"] = actions.delete_buffer,
        }
      }
    },
  },
}

telescope.load_extension('fzf')
-- TODO: add nvim-telescope/telescope-symbols.nvim source for work icons

local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>b', builtin.buffers, bufopts)
vim.keymap.set('n', '<leader>B', builtin.oldfiles, bufopts)

vim.keymap.set('n', '<leader>f', builtin.git_files, bufopts)
vim.keymap.set('n', '<leader>F', builtin.find_files, bufopts)

vim.keymap.set('n', '<leader>tj', builtin.resume, bufopts)

vim.keymap.set('n', '<leader>g', builtin.live_grep, bufopts)
vim.keymap.set('n', '<leader>G', builtin.current_buffer_fuzzy_find, bufopts)
vim.keymap.set('n', '<leader>tt', builtin.tags, bufopts)
vim.keymap.set('n', '<leader>tT', builtin.current_buffer_tags, bufopts)

vim.keymap.set('n', '<leader>tq', builtin.quickfix, bufopts)
vim.keymap.set('n', '<leader>tr', builtin.registers, bufopts)
vim.keymap.set('n', '<leader>ts', builtin.spell_suggest, bufopts)

vim.keymap.set('n', '<leader>loc', builtin.git_commits, bufopts)
vim.keymap.set('n', '<leader>lod', builtin.git_bcommits, bufopts)
vim.keymap.set('n', '<leader>lob', builtin.git_branches, bufopts)
vim.keymap.set('n', '<leader>lot', builtin.git_stash, bufopts)

vim.keymap.set('n', '<leader>d', builtin.diagnostics, bufopts) -- gives diagnostics for whole workspace
vim.keymap.set('n', '<leader>tr', builtin.treesitter, bufopts)
vim.keymap.set('n', '<leader>tmt', builtin.lsp_type_definitions, bufopts)
vim.keymap.set('n', '<leader>tmd', builtin.lsp_definitions, bufopts)

vim.keymap.set('n', '<leader>lii', builtin.lsp_incoming_calls, bufopts) -- no typescript/angular
vim.keymap.set('n', '<leader>lio', builtin.lsp_outgoing_calls, bufopts) -- no typescript/angular
vim.keymap.set('n', '<leader>lyl', builtin.lsp_document_symbols, bufopts) -- no typescipt/angular
vim.keymap.set('n', '<leader>lmi', builtin.lsp_implementations, bufopts) -- no typescript/angular

vim.keymap.set('i', '<M-p>', function () vim.cmd('stopinsert') end, bufopts)
