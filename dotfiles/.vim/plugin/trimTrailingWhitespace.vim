" Trims trailing whitespace on write
" In order to disable this for certain filetypes:
" let b:noTrimTWS = 1
" Maintainer:       Glenn Moss <glennimoss@gmail.com>
" Latest Revision:  2013-04-12
if exists('g:loaded_trimTrailingWhitespace')
    finish
endif
let g:loaded_trimTrailingWhitespace = 1

let s:cpo_save = &cpo
set cpo&vim

augroup trimTWS
  autocmd BufWritePre * if !exists('b:noTrimTWS') | silent %s/\s\+$//e | endif
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
