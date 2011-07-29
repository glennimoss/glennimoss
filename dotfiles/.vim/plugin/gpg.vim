if has("autocmd")

" Support editing of gpg-encrypted files
augroup gnupg
  " Remove all gnupg autocommands
  au!

  " Enable editing of gpg-encrypted files
  " Inspired from the gzip section of Debian's /etc/vimrc
  " By Bill Jonas, bill@billjonas.com
  "	  read:	set binary mode before reading the file
  "		decrypt text in buffer after reading
  "	 write:	encrypt file after writing
  "	append:	decrypt file, append, encrypt file
  "make sure nothing is written to ~/.viminfo
  autocmd BufReadPre,FileReadPre	*.gpg,*.asc set viminfo=
  "turn off swapfile so unencrypted data is not written to disk
  autocmd BufReadPre,FileReadPre	*.gpg,*.asc set noswapfile
  " read file in binary mode
  autocmd BufReadPre,FileReadPre	*.gpg,*.asc set bin
  autocmd BufReadPre,FileReadPre	*.gpg,*.asc let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost	*.gpg,*.asc 1;'[,']!gpg --use-agent -d 2>/dev/null
  "switch to normal mode for editing
  autocmd BufReadPost,FileReadPost	*.gpg,*.asc set nobin
  autocmd BufReadPost,FileReadPost	*.gpg,*.asc let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost	*.gpg,*.asc execute ":doautocmd BufReadPost " . expand("%:r")

  autocmd BufWritePre,FileWritePre	*.gpg,*.asc set bin
  autocmd BufWritePre,FileWritePre	*.gpg 1;'[,']!gpg --use-agent -o - -e
  autocmd BufWritePre,FileWritePre	*.asc 1;'[,']!gpg --use-agent -a -o - -e
  autocmd BufWritePost,FileWritePost	*.gpg,*.asc set nobin
  autocmd BufWritePost,FileWritePost	*.gpg,*.asc undo

  autocmd FileAppendPre			*.gpg,*.asc !gpg --use-agent -d <afile> 2>/dev/null ><afile>:r
  autocmd FileAppendPre			*.gpg,*.asc !mv <afile>:r <afile>
  autocmd FileAppendPost		*.gpg,*.asc !mv <afile> <afile>:r
  autocmd FileAppendPost		*.gpg !gpg -o <afile> -e <afile>:r
  autocmd FileAppendPost		*.asc !gpg -a -o <afile> -e <afile>:r
  autocmd FileAppendPost		*.gpg,*.asc !rm <afile>:r
augroup END

endif
