" Bender's hacked up php indent file
" Language: PHP
" Author:  John Wellesz <John.wellesz (AT) teaser (DOT) fr>
" Author:  Johannes Zellner <johannes@zellner.org>
" Author: Bryan Davis <bender@casadebender.com>
" Last Change:  2007 November 12th
" Version:  1.02 SVN: $Id$
"
" I took John Wellesz's php indenter, added html formatting from Johannes
" Zellner's html indenter and fixed up some stuff I didn't like about how it
" worked (specifically the select/case indenting of John's script and the
" indenting of multiline arrays and function declarations) I also gave
" Johannes' script responsibilty for indenting <script> blocks.
" -- Bryan Davis
"

" NOTE: This script must be used with PHP syntax ON and with the php syntax
"  script by Lutz Eymers (http://www.isp.de/data/php.vim ) that's the script
"  bundled with vim.
"
"
"  In the case you have syntax errors in your script such as end of HereDoc
"  tags not at col 1 you'll have to indent your file 2 times (This script
"  will automatically put HereDoc end tags at col 1).
"

" NOTE: If you are editing file in Unix file format and that (by accident)
" there are '\r' before new lines, this script won't be able to proceed
" correctly and will make many mistakes because it won't be able to match
" '\s*$' correctly.
" So you have to remove those useless characters first with a command like:
"
" :%s /\r$//g
"
" or simply 'let' the option PHP_removeCRwhenUnix to 1 and the script will
" silently remove them when VIM load this script (at each bufread).


" Options: PHP_default_indenting = # of sw (default is 0), # of sw will be
"       added to the indent of each line of PHP code.
"
" Options: PHP_removeCRwhenUnix = 1 to make the script automatically remove CR
"       at end of lines (by default this option is unset), NOTE that you
"       MUST remove CR when the fileformat is UNIX else the indentation
"       won't be correct...
"

" Remove all the comments from this file:
" :%s /^\s*".*\({{{\|xxx\)\@<!\n\c//g
" }}}

" The 4 following lines prevent this script from being loaded several times per buffer.
" They also prevent the load of different indent scripts for PHP at the same time.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

"echom "Hello World! This is Bender's hacked php indent mode."

"  This script set the option php_sync_method of PHP syntax script to 0
"  (fromstart indenting method) in order to have an accurate syntax.
"  If you are using very big PHP files (which is a bad idea) you will
"  experience slowings down while editing, if your code contains only PHP
"  code you can comment the line below.
let php_sync_method = 0

" Apply PHP_default_indenting option
if exists("PHP_default_indenting")
  let b:PHP_default_indenting = PHP_default_indenting * &sw
else
  let b:PHP_default_indenting = 0
endif

let b:PHP_lastindented = 0
let b:PHP_indentbeforelast = 0
let b:PHP_indentinghuge = 0
let b:PHP_CurrentIndentLevel = b:PHP_default_indenting
let b:PHP_LastIndentedWasComment = 0
let b:PHP_InsideMultilineComment = 0
" PHP code detect variables
let b:InPHPcode = 0
let b:InPHPcode_checked = 0
let b:InPHPcode_tofind = ""
let b:PHP_oldchangetick = b:changedtick
let b:UserIsTypingComment = 0
let b:optionsset = 0

" The 4 options belows are overridden by indentexpr so they are always off
" anyway...
setlocal nosmartindent
setlocal noautoindent
setlocal nocindent
" autoindent must be on, so the line below is also useless...
setlocal nolisp

"setlocal indentexpr=GetPhpIndent()
"setlocal indentkeys=0{,0},0),:,!^F,o,O,e,*<Return>,=?>,=<?,=*/
setlocal indentexpr=GetPhpHtmlIndent(v:lnum)
setlocal indentkeys=0{,0},0),:,!^F,o,O,e,*<Return>,=?>,=<?php,=*/,>

let s:searchpairflags = 'bWr'

" Clean CR when the file is in Unix format
if &fileformat == "unix" && exists("PHP_removeCRwhenUnix") && PHP_removeCRwhenUnix
  silent! %s/\r$//g
endif

" Only define the functions once per Vim session.
if exists("*GetPhpIndent")
  finish " XXX
endif

let s:endline= '\s*\%(//.*\|#.*\|/\*.*\*/\s*\)\=$'
let s:PHP_startindenttag = '<?php\%(.*?>\)\@!'
"setlocal debug=msg " XXX


function! GetLastRealCodeLNum(startline) " {{{
  "Inspired from the function SkipJavaBlanksAndComments by Toby Allsopp for
  "indent/java.vim
  let lnum = a:startline
  let old_lnum = lnum

  while lnum > 1
    let lnum = prevnonblank(lnum)
    let lastline = getline(lnum)

    " if we are inside an html <script> we must skip ?> tags to indent
    " everything as php
    if lastline =~ '^\s*?>.*<?\%(php\)\=\s*$'
      let lnum = lnum - 1
    elseif lastline =~ '^\s*\%(//\|#\|/\*.*\*/\s*$\)'
      " if line is under comment
      let lnum = lnum - 1
    elseif lastline =~ '\*/\s*$'
      " skip multiline comments
      call cursor(lnum, 1)
      if lastline !~ '^\*/'
        call search('\*/', 'W')
        " position the cursor on the first */
      endif
      let lnum = searchpair('/\*', '', '\*/', s:searchpairflags, 'Skippmatch2()')
      " find the most outside /*
      let lastline = getline(lnum)
      if lastline =~ '^\s*/\*'
        " if line contains nothing but comment
        " do the job again on the line before (a comment can hide
        " another...)
        let lnum = lnum - 1
      else
        break
      endif

    elseif lastline =~? '\%(//\s*\|?>.*\)\@<!<?\%(php\)\=\s*$'
      " skip non php code
      while lastline !~ '\(<?php.*\)\@<!?>' && lnum > 1
        let lnum = lnum - 1
        let lastline = getline(lnum)
      endwhile
      if lastline =~ '^\s*?>'
        " if line contains nothing but end tag
        let lnum = lnum - 1
      else
        break
        " else there is something important before the ?>
      endif

      " Manage "here document" tags
    elseif lastline =~? '^\a\w*;$' && lastline !~? s:notPhpHereDoc
      " match the end of a heredoc
      let tofind=substitute( lastline, '\([^;]\+\);', '<<<\1$', '')
      while getline(lnum) !~? tofind && lnum > 1
        let lnum = lnum - 1
      endwhile
    else
      " if none of these were true then we are done
      break
    endif
  endwhile

  if lnum==1 && getline(lnum)!~ '<?php'
    let lnum=0
  endif

  "echom lnum
  "call getchar()
  return lnum
endfunction " }}}

function! Skippmatch2()
  let line = getline(".")
  if line =~ '\%(".*\)\@<=/\*\%(.*"\)\@=' || line =~ '\%(//.*\)\@<=/\*'
    return 1
  else
    return 0
  endif
endfun

function! Skippmatch()  " {{{
  " the slowest instruction of this script, remove it and the script is 3
  " times faster but you may have troubles with '{' inside comments or strings
  " that will break the indent algorithm...
  let synname = synIDattr(synID(line("."), col("."), 0), "name")
  if synname == "Delimiter" || synname == "phpRegionDelimiter" || synname =~# "^phpParent" || synname == "phpArrayParens" || synname =~# "^phpBlock" || synname == "javaScriptBraces" || synname == "phpComment" && b:UserIsTypingComment
    return 0
  else
    "  echom synname
    "  call getchar()
    return 1
  endif
endfun " }}}

function! FindOpenBracket(lnum) " {{{
  " set the cursor to the start of the lnum line
  call cursor(a:lnum, 1)
  return searchpair('{', '', '}', 'bW', 'Skippmatch()')
endfun " }}}

function! FindTheIfOfAnElse (lnum, StopAfterFirstPrevElse) " {{{
  " A very clever recoursive function created by me (John Wellesz) that find the "if" corresponding to an
  " "else". This function can easily be adapted for other languages :)

  if getline(a:lnum) =~# '^\s*}\s*else\%(if\)\=\>'
    " we do this so we can find the opened bracket to speed up the process
    let beforeelse = a:lnum
  else
    let beforeelse = GetLastRealCodeLNum(a:lnum - 1)
  endif

  if !s:level
    let s:iftoskip = 0
  endif

  " If we found another "else" then it means we need to skip the next "if"
  " we'll found. (since version 1.02)
  if getline(beforeelse) =~# '^\s*\%(}\s*\)\=else\%(\s*if\)\@!\>'
    let s:iftoskip = s:iftoskip + 1
  endif

  " A closing bracket? let skip the whole block to save some recursive calls
  if getline(beforeelse) =~ '^\s*}'
    let beforeelse = FindOpenBracket(beforeelse)

    " Put us on the block starter
    if getline(beforeelse) =~ '^\s*{'
      let beforeelse = GetLastRealCodeLNum(beforeelse - 1)
    endif
  endif


  if !s:iftoskip && a:StopAfterFirstPrevElse && getline(beforeelse) =~# '^\s*\%([}]\s*\)\=else\%(if\)\=\>'
    return beforeelse
  endif

  " if there was an else, then there is a if...
  if getline(beforeelse) !~# '^\s*if\>' && beforeelse>1 || s:iftoskip && beforeelse>1

    if  s:iftoskip && getline(beforeelse) =~# '^\s*if\>'
      let s:iftoskip = s:iftoskip - 1
    endif

    let s:level =  s:level + 1
    let beforeelse = FindTheIfOfAnElse(beforeelse, a:StopAfterFirstPrevElse)
  endif

  return beforeelse

endfunction " }}}

function! IslinePHP (lnum, tofind) " {{{
  " This function asks to the syntax if the pattern 'tofind' on the line
  " number 'lnum' is PHP code (very slow...).
  let cline = getline(a:lnum)

  if a:tofind==""
    " This correct the issue where lines beginning by a
    " single or double quote were not indented in some cases.
    let tofind = "^\\s*[\"']*\\s*\\zs\\S"
  else
    let tofind = a:tofind
  endif

  " ignore case
  let tofind = tofind . '\c'

  "find the first non blank char in the current line
  let coltotest = match (cline, tofind) + 1

  " ask to syntax what is its name
  let synname = synIDattr(synID(a:lnum, coltotest, 0), "name")

  "  echom synname
  if synname =~ '^php' || synname=="Delimiter"
    return synname
  else
    return ""
  endif
endfunction " }}}

let s:notPhpHereDoc = '\%(break\|return\|continue\|exit\);'
let s:blockstart = '\%(\%(\%(}\s*\)\=else\%(\s\+\)\=\)\=if\>\|else\>\|while\>\|switch\>\|for\%(each\)\=\>\|declare\>\|class\>\|interface\>\|abstract\>\|try\>\|catch\>\|[|&]\)'

" make sure the options needed for this script to work correctly are set here
" for the last time. They could have been overridden by any 'onevent'
" associated setting file...
let s:autorestoptions = 0
if ! s:autorestoptions
  au BufWinEnter,Syntax  *.php,*.php3,*.php4,*.php5  call ResetOptions()
  let s:autorestoptions = 1
endif

function! ResetOptions()
  if ! b:optionsset
    " Set the comment setting to something correct for PHP
    setlocal comments=s1:/*,mb:*,ex:*/,://,:#
    " disable Auto-wrap of text
    setlocal formatoptions-=t
    " Allow formatting of comments with "gq"
    setlocal formatoptions+=q
    " Insert comment leader after hitting <Enter>
    setlocal formatoptions+=r
    " Insert comment leader after hitting o or O in normal mode
    setlocal formatoptions+=o
    " Uses trailing white spaces to detect paragraphs
    setlocal formatoptions+=w
    " Autowrap comments using textwidth
    setlocal formatoptions+=c
    " Do not wrap if you modify a line after textwidth
    setlocal formatoptions+=b
    let b:optionsset = 1
  endif
endfunc

function! GetPhpIndent()
  "##############################################
  "########### MAIN INDENT FUNCTION #############
  "##############################################

  " This detect if the user is currently typing text between each call
  let UserIsEditing=0
  if  b:PHP_oldchangetick != b:changedtick
    let b:PHP_oldchangetick = b:changedtick
    let UserIsEditing=1
  endif

  if b:PHP_default_indenting
    let b:PHP_default_indenting = g:PHP_default_indenting * &sw
  endif

  " current line
  let cline = getline(v:lnum)

  " Let's detect if we are indenting just one line or more than 3 lines
  " in the last case we can slightly optimize our algorithm
  if !b:PHP_indentinghuge && b:PHP_lastindented > b:PHP_indentbeforelast
    if b:PHP_indentbeforelast
      let b:PHP_indentinghuge = 1
      echom 'Large indenting detected, speed optimizations engaged'
    endif
    let b:PHP_indentbeforelast = b:PHP_lastindented
  endif

  " If the line we are indenting isn't directly under the previous non-blank
  " line of the file then deactivate the optimization procedures and reset
  " status variable (we restart for scratch)
  if b:InPHPcode_checked && prevnonblank(v:lnum - 1) != b:PHP_lastindented
    if b:PHP_indentinghuge
      echom 'Large indenting deactivated'
      let b:PHP_indentinghuge = 0
      let b:PHP_CurrentIndentLevel = b:PHP_default_indenting
    endif
    let b:PHP_lastindented = v:lnum
    let b:PHP_LastIndentedWasComment=0
    let b:PHP_InsideMultilineComment=0
    let b:PHP_indentbeforelast = 0

    let b:InPHPcode = 0
    let b:InPHPcode_checked = 0
    let b:InPHPcode_tofind = ""

  elseif v:lnum > b:PHP_lastindented
    " we are indenting line in > order (we can rely on the line before)
    let real_PHP_lastindented = b:PHP_lastindented
    let b:PHP_lastindented = v:lnum
  endif

  " We must detect if we are in PHPCODE or not, but one time only, then
  " we will detect php end and start tags, comments /**/ and HereDoc
  " tags
  if !b:InPHPcode_checked " {{{ One time check
    let b:InPHPcode_checked = 1

    let synname = ""
    if cline !~ '<?php.*?>'
      " the line could be blank (if the user presses 'return')
      let synname = IslinePHP(prevnonblank(v:lnum), "")
    endif

    if synname != ""
      if synname != "phpHereDoc" && synname != "phpHereDocDelimiter"
        let b:InPHPcode = 1
        let b:InPHPcode_tofind = ""
        if synname == "phpComment"
          let b:UserIsTypingComment = 1
        else
          let b:UserIsTypingComment = 0
        endif
      else
        let b:InPHPcode = 0
        let b:UserIsTypingComment = 0
        let lnum = v:lnum - 1
        while getline(lnum) !~? '<<<\a\w*$' && lnum > 1
          let lnum = lnum - 1
        endwhile

        let b:InPHPcode_tofind = substitute(getline(lnum), '^.*<<<\(\a\w*\)\c', '^\\s*\1;$', '')
      endif
    else
      " IslinePHP returned "" => we are not in PHP or Javascript
      let b:InPHPcode = 0
      let b:UserIsTypingComment = 0
      " Then we have to find a php start tag...
      let b:InPHPcode_tofind = '<?php\%(.*?>\)\@!'
    endif
  endif "!b:InPHPcode_checked }}}

  " Now we know where we are so we can verify the line right above the
  " current one to see if we have to stop or restart php indenting

  " Test if we are indenting PHP code {{{
  " Find an executable php code line above the current line.
  let lnum = prevnonblank(v:lnum - 1)
  let last_line = getline(lnum)

  " If we aren't in php code, then there is something we have to find
  if b:InPHPcode_tofind!=""
    if cline =~? b:InPHPcode_tofind
      let  b:InPHPcode = 1
      let b:InPHPcode_tofind = ""
      let b:UserIsTypingComment = 0
      if cline =~ '\*/'
        " End comment tags must be indented like start comment tags
        call cursor(v:lnum, 1)
        if cline !~ '^\*/'
          call search('\*/', 'W')
        endif
        " find the most outside /*
        let lnum = searchpair('/\*', '', '\*/', s:searchpairflags, 'Skippmatch2()')

        let b:PHP_CurrentIndentLevel = b:PHP_default_indenting

        " prevent a problem if multiline /**/ comment are surrounded by
        " other types of comments
        let b:PHP_LastIndentedWasComment = 0

        if cline =~ '^\s*\*/'
          return indent(lnum) + 1
        else
          return indent(lnum)
        endif

      endif
    endif
  endif

  " ### If we are in PHP code, we test the line before to see if we have to
  " stop indenting
  if b:InPHPcode
    " Was last line containing a PHP end tag ?
    if last_line =~ '\%(<?.*\)\@<!?>\%(.*<?\)\@!' && IslinePHP(lnum, '?>')=~"Delimiter"
      if cline !~? s:PHP_startindenttag
        let b:InPHPcode = 0
        let b:InPHPcode_tofind = s:PHP_startindenttag
      endif

      " Was last line the start of a HereDoc ?
    elseif last_line =~? '<<<\a\w*$'
      let b:InPHPcode = 0
      let b:InPHPcode_tofind = substitute( last_line, '^.*<<<\(\a\w*\)\c', '^\\s*\1;$', '')

      " Skip /* \n+ */ comments except when the user is currently
      " writing them or when it is a comment (ie: not a code put in comment)
    elseif !UserIsEditing && cline =~ '^\s*/\*\%(.*\*/\)\@!' && getline(v:lnum + 1) !~ '^\s*\*'
      let b:InPHPcode = 0
      let b:InPHPcode_tofind = '\*/'

    endif
  endif " }}}

  " Non PHP code is let as it is
  if !b:InPHPcode
    return -1
  endif
  " Align correctly multi // or # lines
  " Indent successive // or # comment the same way the first is {{{
  if cline =~ '^\s*\%(//\|#\|/\*.*\*/\s*$\)'
    if b:PHP_LastIndentedWasComment == 1
      return indent(real_PHP_lastindented)
    endif
    let b:PHP_LastIndentedWasComment = 1
  else
    let b:PHP_LastIndentedWasComment = 0
  endif " }}}

  " Indent multiline /* comments correctly {{{
  "if we are on the start of a MULTI * beginning comment or if the user is
  "currently typing a /* beginning comment.
  if b:PHP_InsideMultilineComment || b:UserIsTypingComment
    if cline =~ '^\s*\*\%(\/\)\@!'
      " if cline == '*'
      if last_line =~ '^\s*/\*'
        " if last_line == '/*'
        return indent(lnum) + 1
      else
        return indent(lnum)
      endif
    else
      let b:PHP_InsideMultilineComment = 0
    endif
  endif

  if !b:PHP_InsideMultilineComment && cline =~ '^\s*/\*' && cline !~ '\*/\s*$'
    " if cline == '/*'
    if getline(v:lnum + 1) !~ '^\s*\*'
      " match indent to previous php line
      return indent(b:PHP_lastindented)
    endif
    let b:PHP_InsideMultilineComment = 1
  endif " }}}

  " Some tags are always indented to col 1

  " Things always indented at col 1 (PHP delimiter: <?, ?>, Heredoc end) {{{
  " PHP start tags are always at col 1, useless to indent unless the end tag
  " is on the same line
  if cline =~# '^\s*<?php' && cline !~ '?>'
    return 0
  endif

  " PHP end tags are always at col 1, useless to indent unless if it's
  " followed by a start tag on the same line
  if  cline =~ '^\s*?>' && cline !~# '<?php'
    return 0
  endif

  " put HereDoc end tags at start of lines
  if cline =~? '^\s*\a\w*;$' && cline !~? s:notPhpHereDoc
    return 0
  endif " }}}

  let s:level = 0

  " Find an executable php code line above the current line.
  let lnum = GetLastRealCodeLNum(v:lnum - 1)

  " last line
  let last_line = getline(lnum)
  " by default
  let ind = indent(lnum)
  let endline= s:endline

  if ind==0 && b:PHP_default_indenting
    let ind = b:PHP_default_indenting
  endif

  " Hit the start of the file, use default indent.
  if lnum == 0
    return b:PHP_default_indenting
  endif

  " Search the matching open bracket (with searchpair()) and set the indent
  " of cline to the indent of the matching line.
  if cline =~ '^\s*}\%(}}\)\@!'
    "BENDER WUZ HERE!
    let olnum = FindOpenBracket(v:lnum)
    let oline = getline(olnum)
    " check to see if opening line for this block was a hanging indent
    " from a long argument list
    if oline =~ '\S\+\s*)\s*{'.endline
      call cursor(olnum, 1)
      call search(')\s*{'.endline, 'W')
      let openedparent = searchpair('(', '', ')', 'bW', 'Skippmatch()')
      if openedparent != olnum
        " take indent from parent line
        let ind = indent(openedparent)
      else
        " take indent from open bracket line
        let ind = indent(olnum)
      endif
    else
      " parent is not a function decl, take indent from open brace line
      let ind = indent(olnum)
    endif
    " return to default indent level
    let b:PHP_CurrentIndentLevel = b:PHP_default_indenting
    return ind
  endif

  " Check for end of comment and indent it like its beginning
  if cline =~ '^\s*\*/'
    " End comment tags must be indented like start comment tags
    call cursor(v:lnum, 1)
    if cline !~ '^\*/'
      call search('\*/', 'W')
    endif
    " find the most outside /*
    let lnum = searchpair('/\*', '', '\*/', s:searchpairflags, 'Skippmatch2()')

    let b:PHP_CurrentIndentLevel = b:PHP_default_indenting

    if cline =~ '^\s*\*/'
      return indent(lnum) + 1
    else
      return indent(lnum)
    endif
  endif

  let defaultORcase = '^\s*\%(default\|case\).*:'
  " end case indent with break -or- return
  let caseBreak = '^\s*\%(break\|return.*\);'

  " if the last line is a stated line and it's not indented then why should
  " we indent this one??
  " if optimized mode is active and nor current or previous line are an 'else'
  " or the end of a possible bracketless thing then indent the same as the
  " previous line
  if last_line =~ '[;}]'.endline && last_line !~# defaultORcase
    if ind==b:PHP_default_indenting
      " if no indentation for the previous line
      return b:PHP_default_indenting
    elseif b:PHP_indentinghuge && ind==b:PHP_CurrentIndentLevel && cline !~# '^\s*\%(else\|\%(case\|default\).*:\|[})];\=\)' && last_line !~# '^\s*\%(\%(}\s*\)\=else\)' && getline(GetLastRealCodeLNum(lnum - 1))=~';'.endline
      return b:PHP_CurrentIndentLevel
    endif
  endif

  " used to prevent redundant tests in the last part of the script
  let LastLineClosed = 0

  let terminated = '\%(;\%(\s*?>\)\=\|<<<\a\w*\|}\)'.endline
  " What is a terminated line?
  " - a line terminated by a ";" optionally followed by a "?>"
  " - a HEREDOC starter line (the content of such block is never seen by this script)
  " - a "}" not followed by a "{"

  let unstated   = '\%(^\s*'.s:blockstart.'.*)\|\%(//.*\)\@<!\<e'.'lse\>\)'.endline
  " What is an unstated line?
  " - an "else" at the end of line
  " - a  s:blockstart (if while etc...) followed by anything and a ")" at
  "   the end of line

  " if the current line is an 'else' starting line
  " (to match an 'else' preceded by a '}' is irrelevant and futile - see
  " code above)
  if ind != b:PHP_default_indenting && cline =~# '^\s*else\%(if\)\=\>'
    " prevent optimized to work at next call
    let b:PHP_CurrentIndentLevel = b:PHP_default_indenting
    return indent(FindTheIfOfAnElse(v:lnum, 1))

  elseif cline =~ '^\s*{'
    let previous_line = last_line
    let last_line_num = lnum

    while last_line_num > 1
      if previous_line =~ '^\s*\%(' . s:blockstart . '\|\%([a-zA-Z]\s*\)*function\)' && previous_line !~ '^\s*[|&]'

        let ind = indent(last_line_num)
        return ind
      endif

      let last_line_num = last_line_num - 1
      let previous_line = getline(last_line_num)
    endwhile

  elseif last_line =~# unstated && cline !~ '^\s*{\|^\s*);\='.endline
    let ind = ind + &sw
    return ind

    " If the last line is terminated by ';' or if it's a closing '}'
    " We need to check if this isn't the end of a multilevel non '{}'
    " structure such as:
    " Exemple:
    "      if ($truc)
    "        echo 'truc';
    "
    "  OR
    "
    "      if ($truc)
    "        while ($truc) {
    "          lkhlkh();
    "          echo 'infinite loop\n';
    "        }
    "
    "  OR even (ADDED for version 1.17 - no modification required )
    "
    "      $thing =
    "        "something";
  elseif ind != b:PHP_default_indenting && last_line =~ terminated
    " If we are here it means that the previous line is:
    " - a *;$ line
    " - a [beginning-blanck] } followed by anything but a { $
    let previous_line = last_line
    let last_line_num = lnum
    let LastLineClosed = 1
    " The idea here is to check if the current line is after a non '{}'
    " structure so we can indent it like the top of that structure.
    " The top of that structure is characterized by a if (ff)$ style line
    " preceded by a stated line. If there is no such structure then we
    " just have to find two 'normal' lines following each other with the
    " same indentation and with the first of these two lines terminated by
    " a ; or by a }...

    while 1
      " let's skip '{}' blocks
      if previous_line =~ '^\s*}'
        " find the opening '{'
        let last_line_num = FindOpenBracket(last_line_num)

        " if the '{' is alone on the line get the line before
        if getline(last_line_num) =~ '^\s*{'
          let last_line_num = GetLastRealCodeLNum(last_line_num - 1)
        endif

        let previous_line = getline(last_line_num)

        continue
      else
        " At this point we know that the previous_line isn't a closing
        " '}' so we can check if we really are in such a structure.

        " it's not a '}' but it could be an else alone...
        if getline(last_line_num) =~# '^\s*else\%(if\)\=\>'
          let last_line_num = FindTheIfOfAnElse(last_line_num, 0)
          " re-run the loop (we could find a '}' again)
          continue
        endif

        " So now it's ok we can check :-)
        " A good quality is to have confidence in oneself so to know
        " if yes or no we are in that struct lets test the indent of
        " last_line_num and of last_line_num - 1!
        " If those are == then we are almost done.
        "
        " That isn't sufficient, we need to test how the first of the
        " 2 lines is ended...

        " Remember the 'topest' line we found so far
        let last_match = last_line_num

        let one_ahead_indent = indent(last_line_num)
        let last_line_num = GetLastRealCodeLNum(last_line_num - 1)
        let two_ahead_indent = indent(last_line_num)
        let after_previous_line = previous_line
        let previous_line = getline(last_line_num)


        " If we find a '{' or a case/default then we are inside that block so lets
        " indent properly... Like the line following that block starter
        if previous_line =~# defaultORcase.'\|{'.endline
          break
        endif

        " The 3 lines below are not necessary for the script to work
        " but it makes it work a little more faster in some (rare) cases.
        " We verify if we are at the top of a non '{}' struct.
        if after_previous_line=~# '^\s*'.s:blockstart.'.*)'.endline && previous_line =~# '[;}]'.endline
          break
        endif

        if one_ahead_indent == two_ahead_indent || last_line_num < 1
          " So the previous line and the line before are at the same
          " col. Now we just have to check if the line before is a ;$ or [}]$ ended line
          " we always check the most ahead line of the 2 lines so
          " it's useless to match ')$' since the lines couldn't have
          " the same indent...
          if previous_line =~# '[;}]'.endline || last_line_num < 1
            break
          endif
        endif
      endif
    endwhile

    if indent(last_match) != ind
      " let's use the indent of the last line matched by the algorithm above
      let ind = indent(last_match)
      " line added in version 1.02 to prevent optimized mode
      " from acting in some special cases
      let b:PHP_CurrentIndentLevel = b:PHP_default_indenting

      " case and default are indented 1 level below
      if cline =~# defaultORcase
        let ind = ind - &sw
      endif
      return ind
    endif
    " if nothing was done lets the old script continue
  endif

  let plinnum = GetLastRealCodeLNum(lnum - 1)
  " previous to last line
  let pline = getline(plinnum)

  " REMOVE comments at end of line before treatment
  " the first part of the regex removes // from the end of line when they are
  " followed by a number of '"' which is a multiple of 2. The second part
  " removes // that are not followed by any '"'
  " Sorry for this unreadable thing...
  let last_line = substitute(last_line,"\\(//\\|#\\)\\(\\(\\([^\"']*\\([\"']\\)[^\"']*\\5\\)\\+[^\"']*$\\)\\|\\([^\"']*$\\)\\)",'','')


  if ind == b:PHP_default_indenting
    if last_line =~ terminated
      let LastLineClosed = 1
    endif
  endif

  " Indent blocks enclosed by {} or () (default indenting)
  if !LastLineClosed
    " the last line isn't a .*; or a }$ line
    " Indent correctly multilevel and multiline '(.*)' things

    " if the last line is a ($ or a multiline function call (or array
    " declaration) with already one parameter on the opening ( line
    if last_line =~# '('.endline || last_line =~? '\h\w*\s*(.*,'.endline && pline !~ '[,(]'.endline
      "BENDER WUZ HERE!
      if last_line !~# '^\s*{'
        " last line wasn't a block open, double the indent for the currnet
        " line
        let ind = ind + (&sw * 2)
      endif

    " If the last line isn't empty and ends with a '),' then check if the
    " ')' was opened on the same line, if not it means it closes a
    " multiline '(.*)' thing and that the current line need to be
    " de-indented one time.
    elseif last_line =~ '\s*),'.endline
      call cursor(lnum, 1)
      call search('),'.endline, 'W')
      let openedparent = searchpair('(', '', ')', 'bW', 'Skippmatch()')
      if openedparent != lnum
        let ind = indent(openedparent)
      endif

    " if the last line is a {$
    elseif last_line =~# '{'.endline
      " If the last line isn't empty and ends with a ') {' then check if
      " ')' was opened on the same line, if not it means it closes a
      " multiline '(.*)' thing and that the current line need to be
      " de-indented one time.
      if last_line =~ '\S\+\s*)\s*{'.endline
        "BENDER WUZ HERE!
        call cursor(lnum, 1)
        call search(')\s*{'.endline, 'W')
        let openedparent = searchpair('(', '', ')', 'bW', 'Skippmatch()')
        if openedparent != lnum
          let ind = indent(openedparent)
        endif
      endif

      if last_line !~# '^\s*{'
        let ind = ind + &sw
      endif

      if cline !~# defaultORcase
        " case and default are not indented inside blocks
        let b:PHP_CurrentIndentLevel = ind
        return ind
      endif

    " If the last line is an assignment that is being continued across
    " multiple lines (watch out for hashtable assignments!)
    elseif last_line =~ '\$\S\+\s*=.*'.endline && last_line !~ ','.endline
      let ind = ind + (&sw * 2)

    " If the last line is a conditional that continues across multiple lines,
    " double indent it
    elseif last_line =~ '\%(if\|while\|for\|foreach\|switch\)\s*(.*'.endline
      let ind = ind + (&sw * 2)

    " In all other cases if the last line isn't terminated indent 1
    " level higher but only if the line before the last line wasn't
    " indented for the same reason.
    elseif cline !~ '^\s*{' && pline =~ '\%(;\%(\s*?>\)\=\|<<<\a\w*\|{\|^\s*'.s:blockstart.'\s*(.*)\)'.endline.'\|^\s*}\|'.defaultORcase
      let ind = ind + &sw

    endif

  elseif last_line =~# defaultORcase
    let ind = ind + &sw
  endif

  " If the current line closes a multiline function call or array def XXX
  if cline =~  '^\s*);\='
    let ind = ind - &sw
    " CASE and DEFAULT are indented at the same level than the SWITCH
  elseif cline =~# defaultORcase &&
        \ (last_line =~# caseBreak || last_line =~# defaultORcase)
    let ind = ind - &sw

  endif

  let b:PHP_CurrentIndentLevel = ind
  return ind
endfunction

"==========================================================================
" guts from indent/html.vim
if exists('g:html_indent_tags')
  unlet g:html_indent_tags
endif

" [-- helper function to assemble tag list --]
function! <SID>HtmlIndentPush(tag)
  if exists('g:html_indent_tags')
    let g:html_indent_tags = g:html_indent_tags.'\|'.a:tag
  else
    let g:html_indent_tags = a:tag
  endif
endfun

" [-- <ELEMENT ? - - ...> --]
call <SID>HtmlIndentPush('a')
call <SID>HtmlIndentPush('abbr')
call <SID>HtmlIndentPush('acronym')
call <SID>HtmlIndentPush('address')
call <SID>HtmlIndentPush('b')
call <SID>HtmlIndentPush('bdo')
call <SID>HtmlIndentPush('big')
call <SID>HtmlIndentPush('blockquote')
call <SID>HtmlIndentPush('button')
call <SID>HtmlIndentPush('caption')
call <SID>HtmlIndentPush('center')
call <SID>HtmlIndentPush('cite')
call <SID>HtmlIndentPush('code')
call <SID>HtmlIndentPush('colgroup')
call <SID>HtmlIndentPush('del')
call <SID>HtmlIndentPush('dfn')
call <SID>HtmlIndentPush('dir')
call <SID>HtmlIndentPush('div')
call <SID>HtmlIndentPush('dl')
call <SID>HtmlIndentPush('em')
call <SID>HtmlIndentPush('fieldset')
call <SID>HtmlIndentPush('font')
call <SID>HtmlIndentPush('form')
call <SID>HtmlIndentPush('frameset')
call <SID>HtmlIndentPush('h1')
call <SID>HtmlIndentPush('h2')
call <SID>HtmlIndentPush('h3')
call <SID>HtmlIndentPush('h4')
call <SID>HtmlIndentPush('h5')
call <SID>HtmlIndentPush('h6')
call <SID>HtmlIndentPush('i')
call <SID>HtmlIndentPush('iframe')
call <SID>HtmlIndentPush('ins')
call <SID>HtmlIndentPush('kbd')
call <SID>HtmlIndentPush('label')
call <SID>HtmlIndentPush('legend')
call <SID>HtmlIndentPush('map')
call <SID>HtmlIndentPush('menu')
call <SID>HtmlIndentPush('noframes')
call <SID>HtmlIndentPush('noscript')
call <SID>HtmlIndentPush('object')
call <SID>HtmlIndentPush('ol')
call <SID>HtmlIndentPush('optgroup')
" call <SID>HtmlIndentPush('pre')
call <SID>HtmlIndentPush('q')
call <SID>HtmlIndentPush('s')
call <SID>HtmlIndentPush('samp')
call <SID>HtmlIndentPush('script')
call <SID>HtmlIndentPush('select')
call <SID>HtmlIndentPush('small')
call <SID>HtmlIndentPush('span')
call <SID>HtmlIndentPush('strong')
call <SID>HtmlIndentPush('style')
call <SID>HtmlIndentPush('sub')
call <SID>HtmlIndentPush('sup')
call <SID>HtmlIndentPush('table')
call <SID>HtmlIndentPush('textarea')
call <SID>HtmlIndentPush('title')
call <SID>HtmlIndentPush('tt')
call <SID>HtmlIndentPush('u')
call <SID>HtmlIndentPush('ul')
call <SID>HtmlIndentPush('var')


" [-- <ELEMENT ? O O ...> --]
if !exists('g:html_indent_strict')
  call <SID>HtmlIndentPush('body')
  call <SID>HtmlIndentPush('head')
  call <SID>HtmlIndentPush('html')
  call <SID>HtmlIndentPush('tbody')
endif


" [-- <ELEMENT ? O - ...> --]
if !exists('g:html_indent_strict_table')
  call <SID>HtmlIndentPush('th')
  call <SID>HtmlIndentPush('td')
  call <SID>HtmlIndentPush('tr')
  call <SID>HtmlIndentPush('tfoot')
  call <SID>HtmlIndentPush('thead')
endif

delfun <SID>HtmlIndentPush

let s:cpo_save = &cpo
set cpo-=C

" [-- count indent-increasing tags of line a:lnum --]
function! <SID>HtmlIndentOpen(lnum, pattern)
  let s = substitute('x'.getline(a:lnum),
        \ '.\{-}\(\(<\)\('.a:pattern.'\)\>\)', "\1", 'g')
  let s = substitute(s, "[^\1].*$", '', '')
  return strlen(s)
endfun

" [-- count indent-decreasing tags of line a:lnum --]
function! <SID>HtmlIndentClose(lnum, pattern)
  let s = substitute('x'.getline(a:lnum),
        \ '.\{-}\(\(<\)/\('.a:pattern.'\)\>>\)', "\1", 'g')
  let s = substitute(s, "[^\1].*$", '', '')
  return strlen(s)
endfun

" [-- count indent-increasing '{' of (java|css) line a:lnum --]
function! <SID>HtmlIndentOpenAlt(lnum)
  return strlen(substitute(getline(a:lnum), '[^{]\+', '', 'g'))
endfun

" [-- count indent-decreasing '}' of (java|css) line a:lnum --]
function! <SID>HtmlIndentCloseAlt(lnum)
  return strlen(substitute(getline(a:lnum), '[^}]\+', '', 'g'))
endfun

" [-- return the sum of indents respecting the syntax of a:lnum --]
function! <SID>HtmlIndentSum(lnum, style)
  if a:style == match(getline(a:lnum), '^\s*</')
    if a:style == match(getline(a:lnum), '^\s*</\<\('.g:html_indent_tags.'\)\>')
      let open = <SID>HtmlIndentOpen(a:lnum, g:html_indent_tags)
      let close = <SID>HtmlIndentClose(a:lnum, g:html_indent_tags)
      if 0 != open || 0 != close
        return open - close
      endif
    endif
  endif
  if '' != &syntax &&
        \ synIDattr(synID(a:lnum, 1, 1), 'name') =~ '\(css\|java\).*' &&
        \ synIDattr(synID(a:lnum, strlen(getline(a:lnum)), 1), 'name')
        \ =~ '\(css\|java\).*'
    if a:style == match(getline(a:lnum), '^\s*}')
      return <SID>HtmlIndentOpenAlt(a:lnum) - <SID>HtmlIndentCloseAlt(a:lnum)
    endif
  endif
  return 0
endfun

function! HtmlIndentGet(lnum)
  " Find a non-empty line above the current line.
  let lnum = prevnonblank(a:lnum - 1)

  " Hit the start of the file, use zero indent.
  if lnum == 0
    return 0
  endif

  let restore_ic = &ic
  setlocal ic " ignore case

  " [-- special handling for <pre>: no indenting --]
  if getline(a:lnum) =~ "^<?" && (0< searchpair('<?', '', '?>', 'nWb')
        \ || 0 < searchpair('<?', '', '?>', 'nW'))
    " we're in a line with </pre> or inside <pre> ... </pre>
    return -1
  endif
  if getline(a:lnum) =~ '\c</pre>'
        \ || 0 < searchpair('\c<pre>', '', '\c</pre>', 'nWb')
        \ || 0 < searchpair('\c<pre>', '', '\c</pre>', 'nW')
    " we're in a line with </pre> or inside <pre> ... </pre>
    if restore_ic == 0
      setlocal noic
    endif
    return -1
  endif

  " [-- special handling for <javascript>: use cindent --]
  let js = '<script.*type\s*=\s*.*java'

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " by Tye Zdrojewski <zdro@yahoo.com>, 05 Jun 2006
  " ZDR: This needs to be an AND (we are 'after the start of the pair' AND
  "      we are 'before the end of the pair').  Otherwise, indentation
  "      before the start of the script block will be affected; the end of
  "      the pair will still match if we are before the beginning of the
  "      pair.
  "
  if   0 < searchpair(js, '', '</script>', 'nWb')
        \ && 0 < searchpair(js, '', '</script>', 'nW')
    " we're inside javascript
    if getline(lnum) !~ js && getline(a:lnum) != '</script>'
      if restore_ic == 0
        setlocal noic
      endif
      return cindent(a:lnum)
    endif
  endif

  if getline(lnum) =~ '\c</pre>'
    " line before the current line a:lnum contains
    " a closing </pre>. --> search for line before
    " starting <pre> to restore the indent.
    let preline = prevnonblank(search('\c<pre>', 'bW') - 1)
    if preline > 0
      if restore_ic == 0
        setlocal noic
      endif
      return indent(preline)
    endif
  endif

  let ind = <SID>HtmlIndentSum(lnum, -1)
  let ind = ind + <SID>HtmlIndentSum(a:lnum, 0)

  if restore_ic == 0
    setlocal noic
  endif

  return indent(lnum) + (&sw * ind)
endfun

let &cpo = s:cpo_save
unlet s:cpo_save

" ==========================================================================
" fancy combined indenting function
function! GetPhpHtmlIndent(lnum)
  let php_ind = GetPhpIndent()
  "echom "php ind:" php_ind
  " priority one for php indent script
  if php_ind > -1
    return php_ind
  endif

  let html_ind = HtmlIndentGet(a:lnum)
  "echom "html ind:" html_ind
  if html_ind > -1
    return html_ind
  endif
  return -1
endfunction

" vim: set ts=2 sw=2 sts=2 et:
