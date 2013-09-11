" -*- vim -*-
" FILE: python_fn.vim
" LAST MODIFICATION: 2008-08-28 8:19pm
" (C) Copyright 2001-2005 Mikael Berthe <bmikael@lists.lilotux.net>
" Maintained by Jon Franklin <jvfranklin@gmail.com>
" Version: 1.13

" USAGE:
"
" Save this file to $VIMFILES/ftplugin/python.vim. You can have multiple
" python ftplugins by creating $VIMFILES/ftplugin/python and saving your
" ftplugins in that directory. If saving this to the global ftplugin
" directory, this is the recommended method, since vim ships with an
" ftplugin/python.vim file already.
" You can set the global variable "g:py_select_leading_comments" to 0
" if you don't want to select comments preceding a declaration (these
" are usually the description of the function/class).
" You can set the global variable "g:py_select_trailing_comments" to 0
" if you don't want to select comments at the end of a function/class.
" If these variables are not defined, both leading and trailing comments
" are selected.
" Example: (in your .vimrc) "let g:py_select_leading_comments = 0"
" You may want to take a look at the 'shiftwidth' option for the
" shift commands...
"
" REQUIREMENTS:
" vim (>= 7)
"
" Shortcuts:
"   ]t      -- Jump to beginning of block
"   ]e      -- Jump to end of block
"   ]v      -- Select (Visual Line Mode) block
"   ]<      -- Shift block to left
"   ]>      -- Shift block to right
"   ]#      -- Comment selection
"   ]u      -- Uncomment selection
"   ]c      -- Select current/previous class
"   ]d      -- Select current/previous function
"   GIM changed:
"   ]<up>   -- Jump to previous line with the same/lower indentation
"   ]<down> -- Jump to next line with the same/lower indentation
"   TO:
"   ]k  -- Jump to previous line with the same/lower indentation
"   ]j -- Jump to next line with the same/lower indentation

" Only do this when not done yet for this buffer
if exists("b:loaded_py_ftplugin")
  finish
endif
let b:loaded_py_ftplugin = 1

noremap  ]t   :PBoB<CR>
vnoremap ]t   :<C-U>PBoB<CR>m'gv``
noremap  ]e   :PEoB<CR>
vnoremap ]e   :<C-U>PEoB<CR>m'gv``

map      ]v   ]tV]e
map      ]<   ]tV]e<
vnoremap ]<   <
map      ]>   ]tV]e>
vnoremap ]>   >

noremap  ]#   :call <SID>PythonCommentSelection()<CR>
vnoremap ]#   :call <SID>PythonCommentSelection()<CR>
noremap  ]u   :call <SID>PythonUncommentSelection()<CR>
vnoremap ]u   :call <SID>PythonUncommentSelection()<CR>

map  ]c   :call <SID>PythonSelectObject("class")<CR>
map  ]d   :call <SID>PythonSelectObject("function")<CR>

"map  ]<up>    :call <SID>PythonNextLine(-1)<CR>
"map  ]<down>  :call <SID>PythonNextLine(1)<CR>
" You may prefer use <s-up> and <s-down>... :-)
map  ]k   :call <SID>PythonNextLine(-1)<CR>
map  ]j   :call <SID>PythonNextLine(1)<CR>

" jump to previous class
"map  ]J   :call <SID>PythonDec("class", -1)<CR>
"vmap ]J   :call <SID>PythonDec("class", -1)<CR>

" jump to next class
"map  ]j   :call <SID>PythonDec("class", 1)<CR>
"vmap ]j   :call <SID>PythonDec("class", 1)<CR>

" jump to previous function
map  ]F   :call <SID>PythonDec("function", -1)<CR>
vmap ]F   :call <SID>PythonDec("function", -1)<CR>

" jump to next function
map  ]f   :call <SID>PythonDec("function", 1)<CR>
vmap ]f   :call <SID>PythonDec("function", 1)<CR>

:com! PBoB execute "normal! ".<SID>PythonBoB(line('.'), -1, 1)."G"
:com! PEoB execute "normal! ".<SID>PythonBoB(line('.'), 1, 1)."G"


" Go to a block boundary (-1: previous, 1: next)
" If force_sel_comments is true, 'g:py_select_trailing_comments' is ignored
function! s:PythonBoB(line, direction, force_sel_comments)
  let ln = a:line
  let ind = indent(ln)
  let mark = ln
  let indent_valid = strlen(getline(ln))
  let ln = ln + a:direction
  if (a:direction == 1) && (!a:force_sel_comments) &&
      \ exists("g:py_select_trailing_comments") &&
      \ (!g:py_select_trailing_comments)
    let sel_comments = 0
  else
    let sel_comments = 1
  endif

  while((ln >= 1) && (ln <= line('$')))
    if  (sel_comments) || (match(getline(ln), "^\\s*#") == -1)
      if (!indent_valid)
        let indent_valid = strlen(getline(ln))
        let ind = indent(ln)
        let mark = ln
      else
        if (strlen(getline(ln)))
          if (indent(ln) < ind)
            break
          endif
          let mark = ln
        endif
      endif
    endif
    let ln = ln + a:direction
  endwhile

  return mark
endfunction


" Go to previous (-1) or next (1) class/function definition
function! s:PythonDec(obj, direction)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  else
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
  endif
  let flag = "W"
  if (a:direction == -1)
    let flag = flag."b"
  endif
  let res = search(objregexp, flag)
endfunction


" Comment out selected lines
" commentString is inserted in non-empty lines, and should be aligned with
" the block
function! s:PythonCommentSelection()  range
  let commentString = "#"
  let cl = a:firstline
  let ind = 1000    " I hope nobody use so long lines! :)

  " Look for smallest indent
  while (cl <= a:lastline)
    if strlen(getline(cl))
      let cind = indent(cl)
      let ind = ((ind < cind) ? ind : cind)
    endif
    let cl = cl + 1
  endwhile
  if (ind == 1000)
    let ind = 1
  else
    let ind = ind + 1
  endif

  let cl = a:firstline
  execute ":".cl
  " Insert commentString in each non-empty line, in column ind
  while (cl <= a:lastline)
    if strlen(getline(cl))
      execute "normal! ".ind."|i".commentString
    endif
    execute "normal! \<Down>"
    let cl = cl + 1
  endwhile
endfunction

" Uncomment selected lines
function! s:PythonUncommentSelection()  range
  " commentString could be different than the one from CommentSelection()
  " For example, this could be "# \\="
  let commentString = "#"
  let cl = a:firstline
  while (cl <= a:lastline)
    let ul = substitute(getline(cl),
             \"\\(\\s*\\)".commentString."\\(.*\\)$", "\\1\\2", "")
    call setline(cl, ul)
    let cl = cl + 1
  endwhile
endfunction


" Select an object ("class"/"function")
function! s:PythonSelectObject(obj)
  " Go to the object declaration
  normal! $
  call <SID>PythonDec(a:obj, -1)
  let beg = line('.')

  if !exists("g:py_select_leading_comments") || (g:py_select_leading_comments)
    let decind = indent(beg)
    let cl = beg
    while (cl>1)
      let cl = cl - 1
      if (indent(cl) == decind) && (getline(cl)[decind] == "#")
        let beg = cl
      else
        break
      endif
    endwhile
  endif

  if (a:obj == "class")
    let eod = "\\(^\\s*class\\s\\+[a-zA-Z0-9_]\\+\\s*"
            \ . "\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*\\)\\@<=:"
  else
   let eod = "\\(^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*\\)\\@<=:"
  endif
  " Look for the end of the declaration (not always the same line!)
  call search(eod, "")

  " Is it a one-line definition?
  if match(getline('.'), "^\\s*\\(#.*\\)\\=$", col('.')) == -1
    let cl = line('.')
    execute ":".beg
    execute "normal! V".cl."G"
  else
    " Select the whole block
    execute "normal! \<Down>"
    let cl = line('.')
    execute ":".beg
    execute "normal! V".<SID>PythonBoB(cl, 1, 0)."G"
  endif
endfunction


" Jump to the next line with the same (or lower) indentation
" Useful for moving between "if" and "else", for example.
function! s:PythonNextLine(direction)
  let ln = line('.')
  let ind = indent(ln)
  let indent_valid = strlen(getline(ln))
  let ln = ln + a:direction

  while((ln >= 1) && (ln <= line('$')))
    if (!indent_valid) && strlen(getline(ln))
        break
    else
      if (strlen(getline(ln)))
        if (indent(ln) <= ind)
          break
        endif
      endif
    endif
    let ln = ln + a:direction
  endwhile

  execute "normal! ".ln."G"
endfunction

