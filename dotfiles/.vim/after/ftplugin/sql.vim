" Reimplemented here to fix some problems

" SQL is generally case insensitive
let b:match_ignorecase = 1

" Some standard expressions for use with the matchit strings
let s:notend = '\%(\<end\>\s\+\)\@<!'
let s:notkeywordend = '\%(\(\<if\>\|\<loop\>\|\<case\>\)\@![^;]\)*'
"let s:when_no_matched_or_others = '\%(\<when\>\%(\s\+\%(\%(\<not\>\s\+\)\?<matched\>\)\|\<others\>\)\@!\)'
let s:or_replace = '\%(or\s\+replace\s\+\)\?'

" Handle the following:
" declare
" begin
" end
"
" begin
" end
"
" if
" elseif | elsif
" else [if]
" end if
"
" [while condition] loop
"     leave
"     break
"     continue
"     exit
" end loop
"
" for
"     leave
"     break
"     continue
"     exit
" end loop
"
" do
"     statements
" doend
"
" case
" when
" when
" default
" end case
"
" merge
" when not matched
" when matched
"
" EXCEPTION
" WHEN column_not_found THEN
" WHEN OTHERS THEN
"
" create[ or replace] procedure|function|event

"\ '\<declare\>\|\<procedure\>\|\<function\>:\<begin\>:\%(\<end\>\s*\(\(\<if\>\|\<loop\>\|\<case\>\)\@!.\)*;$\),'.
"\ '\<begin\>:\%(\<end\>\s*' . s:notkeywordend . ';$\),'.
            "\ '\%('.s:when_no_matched_or_others.'\):'.
let b:match_words =
\ '\<begin\>:\%(\<end\>\s*' . s:notkeywordend . ';\),'.
\
            \ s:notend . '\<if\>:'.
            \ '\<elsif\>\|\<elseif\>\|\<else\>:'.
            \ '\<end\s\+if\>,'.
            \
            \ '\%(\<\%(end\|while\|for\)\>\s\+.*\)\@<!\<loop\>\|'.
            \ '\<for\>.*\<loop\>\|\<while\>.*\<loop\>:'.
            \ '\<exit\>\|\<continue\>:'.
            \ '\<end\>\s\+\<loop\>,'.
            \
            \ '\%('. s:notend . '\<case\>\):'.
            \ '\<when\>:' .
            \ '\%(\<end\>\s*\%(\<case\>\s*;\|' . s:notkeywordend . '\)\),' .
            \
            \ '\<merge\>:' .
            \ '\<when\s\+not\s\+matched\>:' .
            \ '\<when\s\+matched\>,' .
            \
            \ '\%(\<create\s\+' . s:or_replace . '\)\?'.
            \ '\%(function\|procedure\|event\):'.
            \ '\<returns\?\>'
            " \ '\<begin\>\|\<returns\?\>:'.
            " \ '\<end\>\(;\)\?\s*$'
            " \ '\<exception\>:'.s:when_no_matched_or_others.
            " \ ':\<when\s\+others\>,'.
"
            " \ '\%(\<exception\>\|\%('. s:notend . '\<case\>\)\):'.
            " \ '\%(\<default\>\|'.s:when_no_matched_or_others.'\):'.
            " \ '\%(\%(\<when\s\+others\>\)\|\<end\s\+case\>\),' .
