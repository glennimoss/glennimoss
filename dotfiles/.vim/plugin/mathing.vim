" Avoid installing twice
if exists('g:loaded_mathing')
    finish
endif
let g:loaded_mathing = 1

function s:Sum ()
  let [l:up, l:left] = getpos("'<")[1:2]
  let [l:down, l:right] = getpos("'>")[1:2]
  if l:up > l:down
    let [l:up, l:down] = [l:down, l:up]
  endif
  if l:left > l:right
    let [l:left, l:right] = [l:right, l:left]
  endif

  let l:text = @*
  let l:frac = matchstr(l:text, "\\.\\d\\+")
  if l:frac == ""
    let Parser = function("str2nr")
    let l:s = 0
    let l:fmt = "%d"
  else
    let Parser = function("str2float")
    let l:s = 0.0
    let l:fmt = "%." . (len(l:frac) - 1) . "f"
  endif
  for l in split(l:text, "\n")
    let l:s += Parser(l)
  endfor
  let l:t = printf(l:fmt, l:s)
  echo "Column: ". l:right
  if append(l:down, printf("%" . l:right . "s", l:t)) == 1
    echo "Total: " . l:t
  endif
  call cursor(l:down + 1, l:right)
endfunction

" Should this be <silent>??
vnoremap <Leader>ts :<C-U>call <SID>Sum()<CR>
command -range TotalSum call <SID>Sum()
