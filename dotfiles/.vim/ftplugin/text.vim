if exists("b:did_text_ftplugin")
  finish
endif
let b:did_text_ftplugin = 1

" Word wrap
set linebreak

" Paragraphs are explicit; don't insert newlines for me
set textwidth=0
set wrapmargin=0

" Make some cool characters double-width
"set ambiwidth=double

noreabbrev <buffer> \forall\ ∀
noreabbrev <buffer> \exists\ ∃
noreabbrev <buffer> \in\ ∈

