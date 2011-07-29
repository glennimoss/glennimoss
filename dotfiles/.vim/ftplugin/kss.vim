" Vim filetype plugin file
" Language:         KSS
" Maintainer:       Glenn Moss <gim@keynetics.com>
" Latest Revision:  2011-03-07

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

let b:undo_ftplugin = "setl com< cms< inc< fo< ofu<"

setlocal comments=s1:/*,mb:*,ex:*/ commentstring&
setlocal formatoptions-=t formatoptions+=croql
setlocal omnifunc=csscomplete#CompleteCSS

let &l:include = '^\s*@import\s\+\%(url(\)\='

let &cpo = s:cpo_save
unlet s:cpo_save
