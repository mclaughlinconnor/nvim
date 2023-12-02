return {
  {
    "lervag/vimtex",
    commit = "941485f8b046ac00763dad2546f0701e85e5e02c",
    init = function()
      vim.cmd([[
        let g:tex_flavor='latex'
        let g:vimtex_view_method = 'zathura'
        let g:vimtex_view_general_viewer = 'zathura'
        let g:vimtex_view_general_options = '--noraise --unique @pdf\#src:@line@tex'
        let g:vimtex_compiler_progname = 'nvr'
        let g:vimtex_quickfix_mode = 2
        let g:vimtex_fold_enabled = 0
        let g:tex_flavor = 'latex'
        let g:vimtex_complete_enabled = 1
        let g:vimtex_view_use_temp_files = 1
        let g:tex_indent_items=0
        let g:tex_indent_and=0
        let g:tex_indent_brace=0
        let g:vimtex_compiler_latexmk = {
            \ 'callback' : 1,
            \ 'continuous' : 1,
            \ 'options' : [
            \   '-pdf' ,
            \   '-shell-escape' ,
            \   '-verbose' ,
            \   '-file-line-error',
            \   '-synctex=1' ,
            \   '-interaction=nonstopmode' ,
            \ ],
            \}
        let g:vimtex_grammar_textidote = {
            \ 'jar': '/usr/share/java/textidote.jar',
            \ 'args': '',
            \}

        function! LatexSurround()
            let b:surround_{char2nr("e")}
            \ = "\\begin{\1environment: \1}\n\t\r\n\\end{\1\1}"
            let b:surround_{char2nr("c")} = "\\\1command: \1{\r}"
        endfunction

        augroup TeX
        autocmd!
        autocmd FileType tex
              \ lua require('cmp').setup.buffer { sources = { { name = 'omni', trigger_characters = { '\\' } } } }
        autocmd FileType tex,latex call vimtex#init()
        autocmd FileType tex,latex call LatexSurround()
        autocmd FileType tex,latex setlocal spell
        autocmd FileType tex,latex set spelllang=en_gb
        autocmd FileType tex,latex syntax spell toplevel
        augroup END
      ]])
    end,
  },
}
