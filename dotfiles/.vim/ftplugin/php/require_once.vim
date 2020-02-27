if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

function! s:AddRequireOnce(className)
  let l:requireLine = "require_once '" . substitute(a:className, '_', '/', 'g') . ".php';"

  let l:lastRequireLine = 0
  let l:state = 0
  let l:foundAny = 0
  let l:i = 0
  for line in getline(1, 100)
    let l:i += 1
    if l:state == 0
      " Finding the opening php tag
      if line ==# "<?php"
        let l:state = 1
        let l:lastRequireLine = l:i
      endif
    elseif l:state == 1
      " See if there's a comment header
      if line =~# '\*'
        let l:state = 2
      else
        let l:state = 3
      endif
    elseif l:state == 2
      " Skip comment header...
      if line !~ '\*'
        let l:state = 3
        let l:lastRequireLine = l:i - 1
      endif
    else
      if line =~# "^require_once "
        let l:foundAny = 1
        let l:lastRequireLine = l:i
        if line ==# l:requireLine
          echo "File already required on line " . l:i
          return
        endif
      endif
    endif
  endfor

  echom "Added " . l:requireLine
  call append(l:lastRequireLine, l:requireLine)

  if !l:foundAny
    " This is the first require_once we're adding so put an extra blank line
    call append(l:lastRequireLine, '')
  endif

endfunction

"function! s:CleanupRequires()
function! CleanupRequires()
  let i = 0
  let todelete = []
  for line in getline(1, 100)
    let i += 1

    let found = matchlist(line, "\\v^require_once '(.+).php';$")
    if len(found)
      let className = substitute(found[1], '/', '_', 'g')
      if !search(className, 'nw')
        call add(todelete, i)
      endif
    endif
  endfor

  for lno in reverse(todelete)
    execute lno "delete _"
  endfor
endfunction

nnoremap <buffer> <LocalLeader>r :call <SID>AddRequireOnce(expand('<cword>'))<CR>
