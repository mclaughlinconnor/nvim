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

function! LatexSurround()
    let b:surround_{char2nr("e")}
    \ = "\\begin{\1environment: \1}\n\t\r\n\\end{\1\1}"
    let b:surround_{char2nr("c")} = "\\\1command: \1{\r}"
endfunction

function RegisterCode(cfg) abort
  " Parse minted macros in the current project
  call s:parse_minted_constructs()

  " Match minted environment boundaries
  syntax match texMintedEnvBgn contained '\\begin{code}'
        \ nextgroup=texMintedEnvOpt,texMintedEnvArg skipwhite skipnl
        \ contains=texCmdEnv
  "
  " Next add nested syntax support for desired languages
  for [l:nested, l:config] in items(b:vimtex.syntax.minted)
    echo (l:nested)
    echo (l:config)
    let l:cluster = vimtex#syntax#nested#include(l:nested)
    echo (l:cluster)

    let l:name = toupper(l:nested[0]) . l:nested[1:]
    let l:grp_env = 'texMintedZone' . l:name
    let l:grp_inline = 'texMintedZoneInline' . l:name
    let l:grp_inline_matcher = 'texMintedArg' . l:name

    let l:options = 'keepend'
    let l:contains = 'contains=texCmdEnv,texMintedEnvBgn'
    let l:contains_inline = ''

    if !empty(l:cluster)
      let l:contains .= ',@' . l:cluster
      let l:contains_inline = '@' . l:cluster
    else
      execute 'highlight def link' l:grp_env 'texMintedZone'
      execute 'highlight def link' l:grp_inline 'texMintedZoneInline'
    endif

    " Match normal minted environments
    execute 'syntax region' l:grp_env
          \ 'start="\\begin{code}\%(\_s*\[\_[^\]]\{-}\]\)\?\_s*{' . l:nested . '}"'
          \ 'end="\\end{code}"'
          \ l:options
          \ l:contains
  endfor
endfunction

function s:parse_minted_constructs() abort
  let l:db = deepcopy(s:db)
  let b:vimtex.syntax.minted = l:db.data

  let l:in_multi = 0
  for l:line in vimtex#parser#tex(b:vimtex.tex, {'detailed': 0})
    " Multiline minted environments
    if l:in_multi
      let l:lang = matchstr(l:line, '\]\s*{\zs\w\+\ze}')
      if !empty(l:lang)
        call l:db.register(l:lang)
        let l:in_multi = 0
      endif
      continue
    endif
    if l:line =~# '\\begin{code}\s*\[[^\]]*$'
      let l:in_multi = 1
      continue
    endif

    " Single line minted environments
    let l:lang = matchstr(l:line, '\\begin{code}\%(\s*\[[^\]]*\]\)\?\s*{\zs\w\+\ze}')
    if !empty(l:lang)
      call l:db.register(l:lang)
      continue
    endif
  endfor
endfunction

let s:db = {
\ 'data' : {},
\}

function s:db.register(lang) abort dict
  " Avoid dashes in langnames
  let l:lang = substitute(a:lang, '-', '', 'g')

  if !has_key(self.data, l:lang)
    let self.data[l:lang] = {
          \ 'environments' : [],
          \ 'commands' : [],
          \}
  endif

  let self.cur = self.data[l:lang]
endfunction

function! InitCodeVimtex()
  return
  if g:vimtex_highlight_code_cm == 1
    return
  endif

  g:vimtex_highlight_code_cm = 1
  call vimtex#init()
  " echo b:vimtex.syntax.minted
  call vimtex#syntax#core#init()
  call vimtex#syntax#core#init_post()
  if !has_key(b:vimtex, 'syntax')
    let b:vimtex.syntax = {}
  endif
endfunction

let g:vimtex_highlight_code_cm = 1

augroup TeX
autocmd!
autocmd FileType tex
      \ lua require('cmp').setup.buffer { sources = { { name = 'omni', trigger_characters = { '\\' } } } }
" echo(b:vimtex.syntax)
" autocmd FileType tex,latex call InitCodeVimtex()
" autocmd FileType tex,latex call LatexSurround()
autocmd FileType tex,latex setlocal spell
" autocmd call RegisterCode({})
" autocmd User VimtexEventInitPost call RegisterCode({})
" autocmd FileType tex,latex call RegisterCode({})
" autocmd User VimtexEventInitPost call InitCodeVimtex()
autocmd FileType tex,latex set spelllang=en_gb
autocmd FileType tex,latex syntax spell toplevel
" autocmd! User VimtexEventInitPost call vimtex#syntax#core#init_post()
" autocmd User VimtexEventInitPost call RegisterCode({})
" autocmd BufReadPost *.tex call RegisterCode({})
" autocmd FileType tex,latex echo (b:vimtex.syntax)
augroup END
