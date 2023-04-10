local Job = require("plenary.job")
local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local builtin = require("telescope.builtin")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

local splitByColon = function(str)
  local results = {}

  for word in str:gmatch("[^:]+") do
    local stripped = string.gsub(word, "^%s*(.-)%s*$", "%1")
    table.insert(results, stripped)
  end

  return results
end

local project_files = function(default_text)
  local opts = { default_text = default_text }
  local ok = pcall(builtin.git_files, opts)
  if not ok then
    builtin.find_files(opts)
  end
end

telescope.setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      horizontal = {
        width = 0.95,
        height = 0.95,
        preview_width = 0.4,
      },
      vertical = {
        width = 0.95,
        height = 0.95,
        preview_height = 0.4,
      },
    },
    -- Default configuration for telescope goes here:
    -- config_key = value,
    path_display = { "smart" },
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
        ["<M-;>"] = actions_layout.toggle_preview,
        ["<M-m>"] = actions.cycle_previewers_next,
        ["<M-n>"] = actions.cycle_previewers_prev,
        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
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
        ["<M-m>"] = actions.cycle_previewers_next,
        ["<M-n>"] = actions.cycle_previewers_prev,
        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
      },
    },
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
    git_files = {
      show_untracked = true,
    },
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
      mappings = {
        i = {
          ["<M-d>"] = actions.delete_buffer,
        },
      },
    },
  },
})

telescope.load_extension("fzf")
-- TODO: add nvim-telescope/telescope-symbols.nvim source for work icons

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>b", builtin.buffers, bufopts)
vim.keymap.set("n", "<leader>B", builtin.oldfiles, bufopts)

vim.keymap.set("n", "<leader>f", project_files, bufopts)
vim.keymap.set("n", "<leader>F", function()
  project_files(vim.fn.expand("<cword>"))
end, bufopts)

vim.keymap.set("n", "<leader>tj", builtin.resume, bufopts)

vim.keymap.set("n", "<leader>g", builtin.live_grep, bufopts)
vim.keymap.set("n", "<leader>G", function()
  builtin.live_grep({ default_text = vim.fn.expand("<cword>") })
end, bufopts)
vim.keymap.set("n", "<leader>tg", builtin.current_buffer_fuzzy_find, bufopts)
vim.keymap.set("n", "<leader>tt", builtin.tags, bufopts)
vim.keymap.set("n", "<leader>tT", function()
  builtin.tags({ default_text = vim.fn.expand("<cword>") })
end, bufopts)
vim.keymap.set("n", "<leader>tc", builtin.current_buffer_tags, bufopts)

vim.keymap.set("n", "<leader>tq", builtin.quickfix, bufopts)
vim.keymap.set("n", "<leader>tr", builtin.registers, bufopts)
vim.keymap.set("n", "<leader>ts", builtin.spell_suggest, bufopts)

vim.keymap.set("n", "<leader>loc", builtin.git_commits, bufopts)
vim.keymap.set("n", "<leader>lod", builtin.git_bcommits, bufopts)
vim.keymap.set("n", "<leader>lob", builtin.git_branches, bufopts)
vim.keymap.set("n", "<leader>lot", builtin.git_stash, bufopts)

vim.keymap.set("n", "<leader>dg", builtin.diagnostics, bufopts) -- gives diagnostics for whole workspace
vim.keymap.set("n", "<leader>te", builtin.treesitter, bufopts)

vim.keymap.set("n", "<leader>lii", builtin.lsp_incoming_calls, bufopts) -- no typescript/angular
vim.keymap.set("n", "<leader>lio", builtin.lsp_outgoing_calls, bufopts) -- no typescript/angular
vim.keymap.set("n", "<leader>lyl", builtin.lsp_document_symbols, bufopts) -- no typescipt/angular

vim.keymap.set("i", "<M-p>", function()
  vim.cmd("stopinsert")
end, bufopts)

local translationPicker = function(opts)
  pickers
      .new(opts, {
        prompt_title = "Translation Grep",
        finder = finders.new_dynamic({
          fn = function(prompt)
            if not prompt or #prompt < 5 then
              return {}
            end

            local yml_keys = {}
            local yml_values = {}

            local prompt_filter = prompt
            if opts.strict_value then
              -- prompt_filter = ":.*" .. prompt_filter
              prompt_filter = ":.*key"
            end
            print(prompt_filter)

            Job:new({
              command = "rg",
              interactive = false,
              args = { "-i", "--color", "never", "--type", "yaml", "--no-heading", prompt_filter },
              on_stdout = function(_, line)
                local split = splitByColon(line)
                print(line)
                local key = split[2]
                local value = split[3]
                table.insert(yml_keys, key)
                table.insert(yml_values, value)
              end,
            }):sync()

            if #yml_keys == 0 then
              return {}
            end

            local translation_values = {}


            for i, key in ipairs(yml_keys) do
          print(vim.inspect(

                    {
                      "-i",
                      "--color",
                      "never",
                      "-g",
                      "*.pug",
                      "--no-heading",
                      "--line-number",
                      "--column",
                      "--case-sensitive",
                      -- "\\b" .. key .. "\\b",
                      [[(('|")]].. key ..[[(('|")|\|tr))]],
                    }
          ))
            Job
                  :new({
                    command = "rg",
                    interactive = false,
                    args = {
                      "-i",
                      "--color",
                      "never",
                      "-g",
                      "*.pug",
                      "--no-heading",
                      "--line-number",
                      "--column",
                      "--case-sensitive",
                      -- "\\b" .. key .. "\\b",
                      [[(('|")]].. key ..[[(('|")|\|tr))]],
                    },
                    on_stdout = function(_, line)
                      local split = splitByColon(line)
                      local path = split[1] or "none"
                      local line_number = split[2] or "none"
                      local column_number = split[3] or "none"
                      table.insert(
                        translation_values,
                        { key = key, translation = yml_values[i], path = path, line = line_number, column = column_number }
                      )
                    end,
                  })
                  :sync()
            end

            return translation_values or {}
          end,
          entry_maker = function(entry)
            local display = vim.fn.fnamemodify(entry.path, ':t')
                .. ":"
                .. entry.line
                .. ":"
                .. entry.column
                .. ":"
                .. entry.key
                .. ":"
                .. entry.translation
            return {
              value = entry.key,
              display = display,
              ordinal = display,
              filename = entry.path,
              lnum = tonumber(entry.line),
              col = tonumber(entry.column),
            }
          end,
        }),
        previewer = conf.qflist_previewer(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
          map("i", "<c-space>", actions.to_fuzzy_refine)
          return true
        end,
      })
      :find()
end

vim.keymap.set("n", "<leader>tp", function()
  translationPicker({ strict_value = true })
end, bufopts)

vim.keymap.set("n", "<leader>tP", function()
  translationPicker({ strict_value = false })
end, bufopts)
