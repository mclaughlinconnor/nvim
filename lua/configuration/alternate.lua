-- TODO: this extension is completely unnecessary --- just write your own code.
-- My own code could have different keymaps to go to different files instead of just one switch

return {
  {
    "AndrewRadev/switch.vim",
    commit = "68d269301181835788dcdcb6d5bca337fb954395",
    init = function()
      local switch = vim.api.nvim_create_augroup("SwitchNeogit", {})
      vim.api.nvim_create_autocmd({ "FileType" }, {
        callback = function()
          if not vim.g.loaded_switch then
            return
          end

          vim.b.switch_definitions = {
            vim.g.switch_builtins.javascript_function,
            vim.g.switch_builtins.javascript_arrow_function,
            vim.g.switch_builtins.javascript_es6_declarations,
            { "public", "private" },
          }
        end,
        group = switch,
        pattern = "typescript",
      })
      vim.api.nvim_create_autocmd({ "FileType" }, {
        callback = function()
          if not vim.g.loaded_switch then
            return
          end

          vim.b.switch_definitions = {
            { "pick", "fixup", "reword", "edit", "squash", "exec", "break", "drop", "label", "reset", "merge" },
            { ["^p "] = "fixup " },
            { ["^f "] = "reword " },
            { ["^r "] = "edit " },
            { ["^e "] = "squash " },
            { ["^s "] = "exec " },
            { ["^x "] = "break " },
            { ["^b "] = "drop " },
            { ["^d "] = "label " },
            { ["^l "] = "reset " },
            { ["^t "] = "merge " },
            { ["^m "] = "pick " },
          }
        end,
        group = switch,
        pattern = "NeogitRebaseTodo",
      })
    end,
  },
  {
    "ton/vim-alternate",
    commit = "57a6d2797b3bec39f5c075104082b0c0835535ed",
    init = function()
      vim.g.AlternateExtensionMappings = {
        { [".ts"] = ".pug", [".pug"] = ".ts" },
      }
    end,
    keys = {
      {
        "<leader>ta",
        "<cmd>Alternate<cr>",
        desc = "Switch to alternate file",
      },
    },
  },
}
