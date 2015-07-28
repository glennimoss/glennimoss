if !exists(':DiffOrig')
  command DiffOrig vert new | set bt=nofile | file on-disk:# | r # | 0d | diffthis | wincmd p | diffthis
endif
