---@param type 'buffer'|'vertical'|'horizontal'|'left'|'tab'
local explore = function(type)
  local method
  local directory = vim.fn.expand("%:p:h")
  if type == "left" then
    vim.cmd(":topleft vsplit " .. directory)
  elseif type == "tab" then
    vim.cmd(":tabnew | edit " .. directory)
  else
    local methodMap = {
      buffer = "edit",
      vertical = "vsplit",
      horizontal = "split",
    }
    local methodName = methodMap[type]

    method = vim.cmd[methodName]

    if method == nil then
      return
    end

    method({
      args = { directory },
    })
  end
end

return {
  {
    "stevearc/oil.nvim",
    commit = "bbad9a76b2617ce1221d49619e4e4b659b3c61fc",
    opts = {
      default_file_explorer = true,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
        ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["h"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["zg"] = "actions.toggle_hidden",
        ["gy"] = "actions.yank_entry",
        ["g\\"] = "actions.toggle_trash",
      },
    },
  },
  {
    "tamago324/lir.nvim",
    commit = "969e95bd07ec315b5efc53af69c881278c2b74fa",
    config = function(_, opts)
      require("lir").setup(opts)

      vim.api.nvim_create_user_command("Explore", function()
        explore("buffer")
      end, {force = true})

      vim.api.nvim_create_user_command("Hexplore", function()
        explore("horizontal")
      end, {force = true})

      vim.api.nvim_create_user_command("Lexplore", function()
        explore("left")
      end, {force = true})

      vim.api.nvim_create_user_command("Sexplore", function()
        explore("horizontal")
      end, {force = true})

      vim.api.nvim_create_user_command("Vexplore", function()
        explore("vertical")
      end, {force = true})

      vim.api.nvim_create_user_command("Texplore", function()
        explore("tab")
      end, {force = true})
    end,
    opts = function()
      local lir = require("lir")
      local actions = require("lir.actions")
      local mark_actions = require("lir.mark.actions")
      local clipboard_actions = require("lir.clipboard.actions")

      return {
        show_hidden_files = false,
        ignore = {}, -- { ".DS_Store" "node_modules" } etc.
        devicons = {
          enable = false,
          highlight_dirname = false,
        },
        mappings = {
          ["o"] = actions.edit,
          ["<CR>"] = actions.edit,
          ["l"] = actions.edit,
          ["h"] = actions.up,
          ["<space>"] = actions.up,
          ["<bs>"] = actions.edit,

          ["<esc>"] = function()
            local files = lir.get_context().files

            for _, item in ipairs(files) do
              item.marked = false
            end

            actions.reload()
          end,

          ["s"] = actions.split,
          ["v"] = actions.vsplit,
          ["t"] = actions.tabedit,

          ["A"] = actions.mkdir,
          ["a"] = actions.newfile,
          ["r"] = actions.rename,
          ["Y"] = actions.yank_path,
          ["zh"] = actions.toggle_show_hidden,

          ["m"] = function()
            mark_actions.toggle_mark("n")
            vim.cmd("normal! j")
          end,
          ["y"] = clipboard_actions.copy,
          ["x"] = clipboard_actions.cut,
          ["p"] = clipboard_actions.paste,
          ["d"] = actions.delete,
        },
        hide_cursor = true,
      }
    end,
  },
}
