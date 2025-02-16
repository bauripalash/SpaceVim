"=============================================================================
" vue.vim --- lang#vue layer for SpaceVim
" Copyright (c) 2016-2021 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================


function! SpaceVim#layers#lang#vue#plugins() abort
  let plugins = []
  call add(plugins, ['posva/vim-vue', {'merged' : 0}])
  return plugins
endfunction

function! SpaceVim#layers#lang#vue#health() abort
  call SpaceVim#layers#lang#vue#plugins()
  return 1
endfunction
