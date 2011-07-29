" Vim filetype plugin file
" Maintainer:       Glenn Moss <gim@keynetics.com>
" Latest Revision:  2011-03-07

if exists("b:did_ftplugin_trimTrailingWhitespace")
  finish
endif
let b:did_ftplugin_trimTrailingWhitespace = 1

let s:cpo_save = &cpo
set cpo&vim

autocmd BufWritePre <buffer> :silent %s/\s\+$//e

let &cpo = s:cpo_save
unlet s:cpo_save
