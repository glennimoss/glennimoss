" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Add .vimlocal to the runtimepath for local-specific configs
set runtimepath^=~/.vimlocal

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set autoread            " read changed files, if no unsaved changes
set autochdir           " cd to the directory of the file in the active buffer
set so=5                " always have 5 lines above or below the cursor
set autoindent          " always set autoindenting on
set smartindent         " be smart about indenting new lines
set nobackup            " don't keep a backup file
set viminfo=%,'10,<100,f1,:20,n~/.viminfo
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set ffs=unix,dos,mac    " preferred file format order
set showmatch           " highlight matching brackets
set mat=5               " tenths of a second to blink matching brackets
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set ignorecase          " ignore case when searching
set smartcase           " don't ignore case if pattern contains uppercase
set hidden              " Allow hiding dirty buffers
set visualbell          " don't beep, flash
set t_vb=1              " ditto
set noerrorbells        " don't beep damn it
set wildmenu            " cool statusline tricks
set wildmode=longest:full,full
set fillchars=vert:\ ,stl:\ ,stlnc:\  "no funny fill chars in splitters
set nostartofline       " don't jump from column to cloumn when changin lines
set formatoptions+=r    " add comment formatting stuff
set laststatus=2        " always show status line
set shortmess=atI       " always show short messages
set whichwrap=<,>,h,l   " let cursors movment wrap to next/previous line
set pastetoggle=<M-p>   " easy paste switch
set noicon              "
set title               "
set lazyredraw          " don't redraw during macros
set report=0            " tell me when anything changes
set listchars=tab:\|-,trail:.,extends:>,precedes:<,eol:$
set shellcmdflag=-lc    " Make :! be a login shell so .profile is read
" print format layout
set printoptions=left:0.5in,right:0.5in,top:0.25in,bottom:0.5in,paper:letter
" fancy status line
" buffer number, file name, flags and syntax type, ruler display
let &stl="%<%n %f %([%H%R%W%Y%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]}%{'~'[&pm=='']}%=%-14.(%l,%c%V%) %P"

" Store all swap files in .vim/swap
set dir=~/.vimswap//

if has("gui_running")
  set mousemodel=popup_setpos
else
  set term=builtin_xterm  " use xterm keyboard mappings
endif

syntax on               " enable syntax highlighting
color borland           " set color scheme

set viewoptions=folds   " save flod state
set foldmethod=marker   " fold at markers
set nofoldenable        " folds off by default

set gcr=n:blinkon0      " no blinking gvim cursor
set tags=.tags,tags     " use .tags for tags file
set nojoinspaces        " don't add spaces after period on gpip

"" keyboard shortcuts
let mapleader = "\\"    " use \ as leader char (default, but be safe)

" Better than esc
inoremap kj <Esc>

" Move around windows with one key combo
nmap <A-h> <C-w>h
nmap <A-l> <C-w>l
nmap <A-j> <C-w>j
nmap <A-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k

" Don't use Ex mode, use Q for formatting
nnoremap Q gq

" fancy search and replace short cuts
"nnoremap ;; :%s:::g<Left><Left><Left>
"nnoremap ;' :%s:::cg<Left><Left><Left><Left>

" navigate buffers with meta-right/left
nnoremap <silent><M-Right> :bn<CR>
nnoremap <silent><M-Left> :bp<CR>

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" Enter breaks a line
nnoremap <Enter> i<CR><Esc>

" Enter instert with paste on
nmap <Leader>i :set paste<CR>i

" for when you forget to sudo vim
command! W w !sudo tee % > /dev/null

" Use Python 3 docs
let g:pydoc_cmd = 'pydoc3'

" if +windows support compiled
if has("windows")
  set showtabline=1 " show page tabs if two or more
  set guitablabel=%t
  let g:toggleTabs = 0
  " toggle tabs on/off with F3
  nmap <silent><F3> :if g:toggleTabs == 1<CR>:tabo<CR>:set showtabline=1<CR>:let g:toggleTabs = 0<CR>:else<CR>:tab ball<CR>:set showtabline=2<CR>:let g:toggleTabs = 1<CR>:endif<CR>
  " navigate tabs with ALT-LEFT, ALT-RIGHT
  nmap <silent><M-Right> :if g:toggleTabs == 1<CR>:tabn<CR>:else<CR>:bn<CR>:endif<CR>
  nmap <silent><M-Left> :if g:toggleTabs == 1<CR>:tabp<CR>:else<CR>:bp<CR>:endif<CR>
  " window navigation
  nnoremap <M-Up> :wincmd W
  nnoremap <M-Down> :wincmd W
endif


if has("vertsplit")
  set equalalways
  set eadirection=ver
end

runtime vimrclocal.vim

call pathogen#infect()

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" mark trailing spaces as an error
highlight InvalidWhitespace ctermbg=red guibg=red
match InvalidWhitespace  /\s\+$/

" mixed spaces and tabs is error
"syntax match Error / \+\t/ containedin=ALL
2match InvalidWhitespace  / \+\t *\| *\t \+/

" lines over 80 chars are error colored
"syntax match OverLength /\%81v.\+/ containedin=ALL

function! ToggleHLSearch()
  if &hls
    set nohlsearch
  else
    set hlsearch
  endif
endfunction
nmap <silent> <C-n> <Esc>:call ToggleHLSearch()<CR>

" path for find commands (cwd + projects dir + pear)
set path+=.,/home/gim/projects/**

" tweaks for php indenter
let PHP_removeCRwhenUnix=1

set shiftwidth=2
set tabstop=2
set softtabstop=0
set expandtab
set textwidth=80
set cino=>1s,n-1s,:1s,=1s,(2s,+2s
set cink=0{,0},:,!^F,!<Tab>,o,O,e

if has("autocmd")
  augroup Vimrc
    "remove ALL autocommands for the current group
    autocmd!

    autocmd BufEnter * :syntax sync fromstart " ensure full syntax hilighting

    " underline current line in insert mode
    autocmd InsertLeave * se nocul nopaste
    autocmd InsertEnter * se cul

    " java files
    let java_highlight_java_lang_ids=1
    let java_highlight_all=1
    let java_allow_cpp_keywords=1
    let java_highlight_debug=1

    " c, h files
    let c_syntax_for_h=1

    let b:closetag_html_style=1
    autocmd Filetype html,xml,xsl,php source ~/.vim/scripts/closetag.vim

    " svn commits
    autocmd BufNewFile,BufRead  svn-commit.* setf svn
    autocmd FileType svn map <Leader>sd :SVNCommitDiff<CR>
    let SVNCommandEnableBufferSetup=1
    let SVNCommandCommitOnWrite=1
    let SVNCommandEdit='split'
    let SVNCommandNameResultBuffers=1

    " perl
    let perl_extended_vars=1 " highlight advanced perl vars inside strings

    " don't expand tabs to spaces in makefiles
    autocmd BufNewFile,BufRead [Mm]akefile* setlocal noet
  augroup END

  augroup JumpCursorOnEdit
    "remove ALL autocommands for the current group
    autocmd!

    autocmd BufReadPost *
          \ if expand("<afile>:p:h") !=? $TEMP |
          \   if line("'\"") > 1 && line("'\"") <= line("$") |
          \     let JumpCursorOnEdit_foo = line("'\"") |
          \     let b:doopenfold = 1 |
          \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
          \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
          \        let b:doopenfold = 2 |
          \     endif |
          \     exe JumpCursorOnEdit_foo |
          \   endif |
          \ endif
    " Need to postpone using "zv" until after reading the modelines.
    autocmd BufWinEnter *
          \ if exists("b:doopenfold") |
          \   exe "normal zv" |
          \   if(b:doopenfold > 1) |
          \       exe  "+".1 |
          \   endif |
          \   unlet b:doopenfold |
          \ endif
  augroup END

  augroup VimConfig
    autocmd!
    autocmd BufWritePost ~/.vimrc source ~/.vimrc
    autocmd BufWritePost vimrc    source ~/.vimrc
  augroup END

endif

set t_RV=
let g:sparkupNextMapping = '<c-l>'

  " vim: set sw=2 ts=2 sts=2 et :
