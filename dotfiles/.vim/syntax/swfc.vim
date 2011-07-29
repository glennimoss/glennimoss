" sc swf compiler syntax file
" (sc is part of the swftools suite at http://www.swftools.org/)
" Author: Zingus J. Rinkle (zingus gmail com)
" Last Change: Jan 2007

syn clear
syn match   scNumber    "\(\d\+\.\d*\|\d*\.\d\+\|\d\+\)%\?"
syn match   scBBox      "\d\+x\d\+"
syn region  scString start='"' end='"' skip='\\"' keepend
syn match   scCommand   "\.\w\+"
syn region  scComment  start="#" end="$" oneline
syn match   scActionIdentifier "[a-zA-Z]\w\+" contained
syn keyword scActionType var function contained
syn keyword scKeyword new .flash .frame .action
syn region  scActionScript matchgroup=scCommand start=":$" end="\.end" contains=scActionComment,scString,scNumber,scActionIdentifier,scActionType keepend
syn region  scActionComment  start="//" end="$" contained
syn region  scActionComment  start="/\*" end="\*/" contained
"syn match   scValue    "\([A-Za-z_]\w*+\?=\)\@<=\S*"
"syn match   scAttribute "=\@<![A-Za-z_]\w*\(+\?=\)\?"
syn sync fromstart

hi link scCommand           Keyword
hi link scComment           Comment
hi link scString            String
"hi link scValue             String
hi link scBBox              Number
hi link scNumber            Number
hi link scActionScript      Special
hi link scActionIdentifier  Special
hi link scActionComment     Comment
"hi link scAttribute         Type
hi link scActionType        Type
hi link scKeyword           Keyword
