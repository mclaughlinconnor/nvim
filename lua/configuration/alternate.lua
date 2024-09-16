return {
  {
    "AndrewRadev/switch.vim",
    commit = "68d269301181835788dcdcb6d5bca337fb954395",
    init = function()
      vim.g.switch_mapping = ""

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

      vim.cmd([[
        function! SwitchLine(cnt = v:count1) abort
          let tick = b:changedtick
          let start = getpos(".")

          " Call the Switch function cnt times initially
          for n in range(a:cnt)
            Switch
          endfor

          if b:changedtick != tick
            return
          endif

          " Loop through the line, switching and moving forward with `w`
          while v:true
            let pos = getcurpos()
            normal! w

            if pos[1] != getcurpos()[1] || pos == getcurpos()
              break
            endif
            for n in range(1)
              Switch
            endfor
            if b:changedtick != tick
              return
            endif
          endwhile

          call setpos('.', start)
        endfunction
      ]])

      -- Needs to come after vim-repeat is loaded and this is the only way I could come up with
      local switchGroup = vim.api.nvim_create_augroup("TypeScriptIndentOnPaste", {})
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        callback = function()
          vim.cmd([[
            nnoremap <silent> <Plug>(SwitchInLine) :<C-u>call SwitchLine(v:count1)<CR>:call repeat#set("\<Plug>(SwitchInLine)", v:count1)<CR>
            nmap gs <Plug>(SwitchInLine)
          ]])
        end,
        group = switchGroup,
        -- pattern = "*.ts",
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
  -- TODO: this extension is completely unnecessary --- just write your own code.
  -- My own code could have different keymaps to go to different files instead of just one switch
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
