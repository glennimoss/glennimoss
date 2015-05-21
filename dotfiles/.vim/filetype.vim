augroup filetypedetect
  au BufNewFile,BufRead *.tmpl exe "doau filetypedetect BufRead " . fnameescape(expand("<afile>:r"))
augroup END
