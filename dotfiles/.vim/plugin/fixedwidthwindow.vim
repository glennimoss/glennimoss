" Avoid installing twice
if exists('g:loaded_fixedwidthwindow') && !has("gui_running")
    finish
endif
let g:loaded_fixedwidthwindow = 1

function! s:WidthPreservingVSplit()
  let l:winno = winnr()
  windo set wfw
  execute l:winno . "wincmd w"
  set nowfw
  let l:width = winwidth(0)
  let &columns += l:width + 1
  "execute "vertical resize " . (l:width*2 + 1)
  execute l:width . "vs"
endfunction
" Make :vs increase the width to maintain window size, rather than split the
" available space in half
command! Vs call s:WidthPreservingVSplit()

function! s:WidthPreservingClose()
  let l:width = winwidth(0)
  let l:winno = winnr()
  windo set wfw
  set nowfw
  execute l:winno . "wincmd w"
  q
  let &columns -= l:width + 1
endfunction
" Make :Q decrease the width to maintain window size, rather than leave the
" window double size
command! Q call s:WidthPreservingClose()
