"=============================================================================
" vim.vim --- SpaceVim vim layer
" Copyright (c) 2016-2021 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

if exists('s:auto_generate_doc')
  finish
endif


let s:auto_generate_doc = 0

" Load SpaceVim API

let s:SID = SpaceVim#api#import('vim#sid')
let s:JOB = SpaceVim#api#import('job')
let s:SYS = SpaceVim#api#import('system')
let s:FILE = SpaceVim#api#import('file')

function! SpaceVim#layers#lang#vim#plugins() abort
  let plugins = [
        \ ['syngan/vim-vimlint',                     { 'on_ft' : 'vim'}],
        \ ['ynkdir/vim-vimlparser',                  { 'on_ft' : 'vim'}],
        \ ['todesking/vint-syntastic',               { 'on_ft' : 'vim'}],
        \ ]
  call add(plugins,['tweekmonster/exception.vim', {'merged' : 0}])
  call add(plugins,['wsdjeg/vim-lookup', {'merged' : 0}])
  call add(plugins,['Shougo/neco-vim',              { 'on_event' : 'InsertEnter', 'loadconf_before' : 1}])
  if g:spacevim_autocomplete_method ==# 'asyncomplete'
    call add(plugins, ['prabirshrestha/asyncomplete-necovim.vim', {
          \ 'loadconf' : 1,
          \ 'merged' : 0,
          \ }])
  elseif g:spacevim_autocomplete_method ==# 'coc'
    call add(plugins, ['neoclide/coc-neco', {'merged' : 0}])
  elseif g:spacevim_autocomplete_method ==# 'completor'
    " call add(plugins, ['kyouryuukunn/completor-necovim', {'merged' : 0}])
    " This plugin has bug in neovim-qt win 7
    " https://github.com/maralla/completor.vim/issues/250
  endif
  call add(plugins,['tweekmonster/helpful.vim',      {'on_cmd': 'HelpfulVersion'}])
  return plugins
endfunction

function! SpaceVim#layers#lang#vim#config() abort
  let g:scriptease_iskeyword = 0
  call SpaceVim#mapping#gd#add('vim','lookup#lookup')
  call SpaceVim#mapping#space#regesit_lang_mappings('vim', function('s:language_specified_mappings'))
  call SpaceVim#plugins#highlight#reg_expr('vim', '\s*\<fu\%[nction]\>!\?\s*', '\s*\<endf\%[unction]\>\s*')
  if s:auto_generate_doc
    augroup spacevim_layer_lang_vim
      autocmd!
      autocmd BufWritePost *.vim call s:generate_doc()
    augroup END
  endif
endfunction

function! s:generate_doc() abort
  " neovim in windows executable function is broken
  " https://github.com/neovim/neovim/issues/9391
  let fd = expand('%:p')
  let addon_info = s:FILE.findfile('addon-info.json', fd)
  if !empty(addon_info)
    let dir = s:FILE.unify_path(addon_info, ':h')
    if executable('vimdoc') && !s:SYS.isWindows
      call s:JOB.start(['vimdoc', dir])
    elseif executable('python')
      call s:JOB.start(['python', '-m', 'vimdoc', dir])
    endif
  endif
endfunction

function! SpaceVim#layers#lang#vim#set_variable(var) abort

  let s:auto_generate_doc = get(a:var, 'auto_generate_doc', s:auto_generate_doc)

endfunction

function! s:language_specified_mappings() abort
  call SpaceVim#mapping#space#langSPC('nmap', ['l','e'],  'call call('
        \ . string(function('s:eval_cursor')) . ', [])',
        \ 'echo eval under cursor', 1)
  call SpaceVim#mapping#space#langSPC('nmap', ['l','v'],  'call call('
        \ . string(function('s:helpversion_cursor')) . ', [])',
        \ 'echo helpversion under cursor', 1)
  call SpaceVim#mapping#space#langSPC('nmap', ['l','f'], 'call exception#trace()', 'tracing exceptions', 1)
endfunction

function! s:eval_cursor() abort
  let is_keyword = &iskeyword
  set iskeyword+=:
  let cword = expand('<cword>')
  if exists(cword)
    echo  cword . ' is ' eval(cword)
    " if is script function
  elseif cword =~# '^s:' && cword =~# '('
    let sid = s:SID.get_sid_from_path(expand('%'))
    if sid >= 1
      let func = '<SNR>' . sid . '_' . split(cword, '(')[0][2:] . '()'
      try
        echon 'Calling func:' . func . ', result is:' . eval(func)
      catch
        echohl WarningMsg
        echo 'failed to call func: ' . func
        echohl None
      endtry
    else
      echohl WarningMsg
      echo 'can not find SID for current script'
      echohl None
    endif
  else
    echohl WarningMsg
    echon 'can not eval script val:'
    echohl None
    echon cword
  endif
  let &iskeyword = is_keyword
endfunction

function! s:helpversion_cursor() abort
  exe 'HelpfulVersion' expand('<cword>')
endfunction

function! SpaceVim#layers#lang#vim#health() abort
  call SpaceVim#layers#lang#vim#plugins()
  call SpaceVim#layers#lang#vim#config()
  return 1
endfunction
