" Ensure python3 takes precedence
call has('python3')

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif


" This lets me reuse the Vundle commands below
command -nargs=+ Plugin Plug <args>

call plug#begin('~/.vim/bundle')

" Plugins I really use and will never remove:
Plugin 'altercation/vim-colors-solarized'
Plugin 'bkad/CamelCaseMotion'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'andymass/vim-matchup' " Plugin 'matchit.zip'
Plugin 'vim-scripts/scratch.vim'

" These are pretty good:
" File browser
Plugin 'scrooloose/nerdtree'
" Comment code
Plugin 'scrooloose/nerdcommenter'
" Status line
Plugin 'glennimoss/vim-airline'
" Autodetects indent size
Plugin 'tpope/vim-sleuth'
" Char info under cursor with 'ga'
Plugin 'tpope/vim-characterize'
" Indent text object
Plugin 'michaeljsmith/vim-indent-object'
" Rename file and make buffer match
Plugin 'artnez/vim-rename'
" Coffeescript syntax
"Plugin 'kchmck/vim-coffee-script'

" I'm experimenting with these:
" Argument text object
Plugin 'vim-scripts/argtextobj.vim'
" Undo tree UI
"Plugin 'sjl/gundo.vim'
" Trying this instead of gundo
Plugin 'mbbill/undotree'
" Multiple cursors
"Plugin 'terryma/vim-multiple-cursors'
" Unite does everything
"Plugin 'shougo/unite.vim'
" View images in vim??
"Plugin 'tpope/vim-afterimage'
" Git functionality
Plugin 'tpope/vim-fugitive'
" Better .tmux.conf editing
Plugin 'tmux-plugins/vim-tmux'
" Focus events passthrough from tmux
"Plugin 'tmux-plugins/vim-tmux-focus-events'
" Background make process
"Plugin 'tpope/vim-dispatch'
" Diff parts of the same file
Plugin 'AndrewRadev/linediff.vim'
" Punctuation pairs
"Plugin 'LunarWatcher/auto-pairs'  " cohama/lexima.vim is supposed to be good too
" HTML tag closing
Plugin 'alvan/vim-closetag'

" I don't know about these ones:
" Python and PHP Debugger
"Plugin 'fisadev/vim-debug.vim'
" Pending tasks list
Plugin 'fisadev/FixedTaskList.vim'
" Git/mercurial/others diff icons on the side of the file lines
Plugin 'mhinz/vim-signify'
" Python and other languages code checker
"Plugin 'scrooloose/syntastic' " This is deprecated and might be causing a bug with vim-go
" Use ack from vim
Plugin 'mileszs/ack.vim'
" Search results counter, shows "Match N of M matches"
"Plugin 'IndexedSearch'

" I removed these manual plugins (which I probably wasn't using anyways)
" These are their replacement repos if I ever want them back.
"Plugin 'inkarkat/vim-ReplaceWithRegister'

" Golang
Plugin 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
"Plugin 'govim/govim'

"let g:go_debug = ["lsp"]

" Typescript
Plug 'neoclide/coc.nvim', {'branch': 'release', 'for': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact']}
let g:coc_global_extensions = [
  \ 'coc-tsserver'
  \ ]

Plug '~/git/coc-keys', {'for': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact']}

call plug#end()

" Required:
filetype plugin indent on


" disabled: " let g:syntastic_mode_map = { "mode": "passive" }
" disabled: let g:syntastic_always_populate_loc_list=1
" disabled: let g:syntastic_python_python_exec = "/usr/bin/python3"
" disabled: let g:syntastic_python_flake8_exe = "python3 -m flake8.run"
" disabled: let g:syntastic_python_checkers = ["flake8", "pep257"]
" disabled: " Ignore indentation not being a multiple of 4:
" disabled: "let g:syntastic_python_flake8_quiet_messages = {"regex":"\\[E111\\]$"}
" disabled: " This set of ignores matches my personal style
" disabled: let g:syntastic_python_flake8_quiet_messages = {"regex":"\\[E\\(111\\|121\\|124\\|125\\|129\\|211\\|231\\)\\]$"}

" Comment this line to enable autocompletion preview window
" (displays documentation related to the selected completion option)
" Disabled by default because preview makes the window flicker
set completeopt-=preview

set completeopt+=popup
set completepopup=align:menu,border:off,highlight:Pmenu

set undofile                      " persistent undos - undo after you re-open the file
set undodir=~/.vimswap
"let g:yankring_history_dir = '~/.vimswap/'

" NERDTree -----------------------------

" toggle nerdtree display
map <F3> :NERDTreeToggle<CR>
" open nerdtree with the current file selected
nmap ,t :NERDTreeFind<CR>
" don;t show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']
let NERDTreeWinPos = "right"


" Tasklist ------------------------------

" show pending tasks list
map <F2> :TaskList<CR>

" Vim-debug ------------------------------

" disable default mappings, have a lot of conflicts with other plugins
let g:vim_debug_disable_mappings = 1
" add some useful mappings
"map <F5> :Dbg over<CR>
"map <F6> :Dbg into<CR>
"map <F7> :Dbg out<CR>
"map <F8> :Dbg here<CR>
"map <F9> :Dbg break<CR>
"map <F10> :Dbg watch<CR>
"map <F11> :Dbg down<CR>
"map <F12> :Dbg up<CR>

" CtrlP ------------------------------

"" file finder mapping
"let g:ctrlp_map = ',e'
"" tags (symbols) in current file finder mapping
"nmap ,g :CtrlPBufTag<CR>
"" tags (symbols) in all files finder mapping
"nmap ,G :CtrlPBufTagAll<CR>
"" general code finder in all files mapping
"nmap ,f :CtrlPLine<CR>
"" recent files finder mapping
"nmap ,m :CtrlPMRUFiles<CR>
"" commands finder mapping
"nmap ,c :CtrlPCmdPalette<CR>
"" to be able to call CtrlP with default search text
"function! CtrlPWithSearchText(search_text, ctrlp_command_end)
"    execute ':CtrlP' . a:ctrlp_command_end
"    call feedkeys(a:search_text)
"endfunction
"" same as previous mappings, but calling with current word as default text
"nmap ,wg :call CtrlPWithSearchText(expand('<cword>'), 'BufTag')<CR>
"nmap ,wG :call CtrlPWithSearchText(expand('<cword>'), 'BufTagAll')<CR>
"nmap ,wf :call CtrlPWithSearchText(expand('<cword>'), 'Line')<CR>
"nmap ,we :call CtrlPWithSearchText(expand('<cword>'), '')<CR>
"nmap ,pe :call CtrlPWithSearchText(expand('<cfile>'), '')<CR>
"nmap ,wm :call CtrlPWithSearchText(expand('<cword>'), 'MRUFiles')<CR>
"nmap ,wc :call CtrlPWithSearchText(expand('<cword>'), 'CmdPalette')<CR>
"" don't change working directory
"let g:ctrlp_working_path_mode = 0
"" ignore these files and folders on file finder
"let g:ctrlp_custom_ignore = {
"  \ 'dir':  '\v[\/](\.git|\.hg|\.svn)$',
"  \ 'file': '\.pyc$\|\.pyo$',
"  \ }

" disabled: " Syntastic ------------------------------
" disabled:
" disabled: " show list of errors and warnings on the current file
" disabled: "nmap <leader>e :Errors<CR>
" disabled: " check also when just opened the file
" disabled: let g:syntastic_check_on_open = 1
" disabled: " don't put icons on the sign column (it hides the vcs status icons of signify)
" disabled: let g:syntastic_enable_signs = 0
" disabled: " custom icons (enable them if you use a patched font, and enable the previous
" disabled: " setting)
" disabled: let g:syntastic_error_symbol = '✗'
" disabled: let g:syntastic_warning_symbol = '⚠'
" disabled: let g:syntastic_style_error_symbol = '✗'
" disabled: let g:syntastic_style_warning_symbol = '⚠'

" Python-mode ------------------------------

"let g:pymode_python = "python3"
"" I don't like pymode's indenting
"let g:pymode_indent = 0
"" don't use linter, we use syntastic for that
"let g:pymode_lint_on_write = 0
"let g:pymode_lint_signs = 0
"" don't fold python code on open
"let g:pymode_folding = 0
"" don't load rope by default. Change to 1 to use rope
"let g:pymode_rope = 1
"" open definitions on same window, and custom mappings for definitions and
"" occurrences
"let g:pymode_rope_goto_definition_bind = ',d'
"let g:pymode_rope_goto_definition_cmd = 'e'
"nmap ,D :tab split<CR>:PymodePython rope.goto()<CR>
"nmap ,o :RopeFindOccurrences<CR>
"let g:pymode_rope_rename_bind = '<Leader>rr'

" NeoComplCache ------------------------------

" most of them not documented because I'm not sure how they work
" (docs aren't good, had to do a lot of trial and error to make
" it play nice)
"let g:neocomplcache_enable_at_startup = 1
"let g:neocomplcache_enable_ignore_case = 1
"let g:neocomplcache_enable_smart_case = 1
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_enable_fuzzy_completion = 1
"let g:neocomplcache_enable_camel_case_completion = 1
"let g:neocomplcache_enable_underbar_completion = 1
"let g:neocomplcache_fuzzy_completion_start_length = 1
"let g:neocomplcache_auto_completion_start_length = 1
"let g:neocomplcache_manual_completion_start_length = 1
"let g:neocomplcache_min_keyword_length = 1
"let g:neocomplcache_min_syntax_length = 1
"" complete with workds from any opened file
"let g:neocomplcache_same_filetype_lists = {}
"let g:neocomplcache_same_filetype_lists._ = '_'

" TabMan ------------------------------

" mappings to toggle display, and to focus on it
"let g:tabman_toggle = 'tl'
"let g:tabman_focus  = 'tf'

" Autoclose ------------------------------

" Fix to let ESC work as espected with Autoclose plugin
"let g:AutoClosePumvisible = {"ENTER": "\<C-Y>", "ESC": "\<ESC>"}

" DragVisuals ------------------------------

" mappings to move blocks in 4 directions
"vmap <expr> <S-M-LEFT> DVB_Drag('left')
"vmap <expr> <S-M-RIGHT> DVB_Drag('right')
"vmap <expr> <S-M-DOWN> DVB_Drag('down')
"vmap <expr> <S-M-UP> DVB_Drag('up')
"" mapping to duplicate block
"vmap <expr> D DVB_Duplicate()

" Signify ------------------------------

" this first setting decides in which order try to guess your current vcs
" UPDATE it to reflect your preferences, it will speed up opening files
let g:signify_vcs_list = [ 'git', 'hg' ]
" mappings to jump to changed blocks
nmap <leader>sn <plug>(signify-next-hunk)
nmap <leader>sp <plug>(signify-prev-hunk)
" nicer colors
highlight DiffAdd           cterm=bold ctermbg=none ctermfg=119
highlight DiffDelete        cterm=bold ctermbg=none ctermfg=167
highlight DiffChange        cterm=bold ctermbg=none ctermfg=227
highlight SignifySignAdd    cterm=bold ctermbg=237  ctermfg=119
highlight SignifySignDelete cterm=bold ctermbg=237  ctermfg=167
highlight SignifySignChange cterm=bold ctermbg=237  ctermfg=227

" Airline ------------------------------

let g:airline_theme = 'solarized'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.whitespace = '␠'
let g:airline#extensions#whitespace#enabled = 0

" Vim-Go ------------------------------

let g:go_doc_keywordprg_enabled = 0

" CamelCaseMotion ---------------------
let g:camelcasemotion_key = ','

" My Settings ==============================================

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set autochdir           " cd to the directory of the file in the active buffer
set autoindent          " always set autoindenting on
set autoread            " read changed files, if no unsaved changes
set diffopt+=vertical,indent-heuristic,algorithm:histogram
set ffs=unix,dos,mac    " preferred file format order
set fillchars=vert:\ ,stl:\ ,stlnc:\  "no funny fill chars in splitters
set formatoptions+=rj   " add comment formatting stuff
set hidden              " Allow hiding dirty buffers
set history=50          " keep 50 lines of command line history
set ignorecase          " ignore case when searching
set incsearch           " do incremental searching
set laststatus=2        " always show status line
set lazyredraw          " don't redraw during macros
set listchars=tab:\|-,trail:·,extends:>,precedes:<,eol:$,nbsp:⍽
set mat=5               " tenths of a second to blink matching brackets
set maxmempattern=10000 " 10mb for crazy big syntaxt matching patterns
set nobackup            " don't keep a backup file
set noerrorbells        " don't beep damn it
set noicon              "
set nopaste             " Some people think paste should be on by default. I don't.
set noshowmode          " Showmode is redundant with airline
set nostartofline       " don't jump from column to cloumn when changin lines
set number              " show number lines (see relativenumber)
set pastetoggle=<M-p>   " easy paste switch
set relativenumber      " Display relative line offsets for lines other than current
set report=0            " tell me when anything changes
set ruler               " show the cursor position all the time
set scrolloff=5         " always have 5 lines above or below the cursor
set shellcmdflag=-lc    " Make :! be a login shell so .profile is read
set shortmess=atI       " always show short messages
set showcmd             " display incomplete commands
set showmatch           " highlight matching brackets
set smartcase           " don't ignore case if pattern contains uppercase
set smartindent         " be smart about indenting new lines
set spelllang=en_us
set t_vb=1              " Use visual bell
set title               "
set viminfo=%,'10,<100,f1,:20,n~/.viminfo
set visualbell          " don't beep, flash
set whichwrap=<,>,h,l   " let cursors movment wrap to next/previous line
set wildmenu            " cool statusline tricks
set wildmode=longest:full,full

if has('patch-7.4.338')
  set breakindent         " Indents wrapped lines
  set breakindentopt=shift:2 " Adds an extra 2 chars to the wrapped indent
  set linebreak           " Wrap words properly
endif

" print format layout
set printoptions=left:0.5in,right:0.5in,top:0.25in,bottom:0.5in,paper:letter
" fancy status line
" buffer number, file name, flags and syntax type, ruler display
let &stl="%<%n %f %([%H%R%W%Y%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]}%{'~'[&pm=='']}%=%-14.(%l,%c%V%) %P"

" Store all swap files here
set dir=~/.vimswap//

if has("gui_running")
  set mousemodel=popup_setpos
elseif !has('nvim')
  set term=builtin_xterm  " use xterm keyboard mappings
endif

if has("mac")
  set clipboard=unnamed
endif

syntax on               " enable syntax highlighting

set viewoptions=folds   " save flod state
set foldmethod=marker   " fold at markers
set nofoldenable        " folds off by default

set gcr=n:blinkon0      " no blinking gvim cursor
set tags=.tags,tags     " use .tags for tags file
set nojoinspaces        " don't add spaces after period on gpip

"" keyboard shortcuts
let mapleader = "-"    " Easier to reach than backslash

" Better than esc
inoremap kj <Esc>

" Move around windows with one key combo
nnoremap <A-h> <C-w>h
nnoremap <A-l> <C-w>l
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k

" Move between buffers with arrows
nnoremap <C-Left> :bp<CR>
nnoremap <C-Right> :bn<CR>

" Go to bottom and top with arrows
nnoremap <C-Up> gg
nnoremap <C-Down> G

" Toggle spell checking
nnoremap <silent> <Leader>s :setlocal spell!<CR>

" Don't use Ex mode, use Q for formatting
"nnoremap Q gq

" fancy search and replace short cuts
"nnoremap ;; :%s:::g<Left><Left><Left>
"nnoremap ;' :%s:::cg<Left><Left><Left><Left>

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" Enter breaks a line
"nnoremap <Enter> i<CR><Esc>
" K Kuts a line (Opposite of J for Join)
nnoremap K i<CR><Esc>

" Enter insert/open line with paste on
nnoremap <Leader>i :set paste<CR>i
nnoremap <Leader>o :set paste<CR>o
nnoremap <Leader>O :set paste<CR>O
nnoremap <Leader>a :set paste<CR>a
nnoremap <Leader>A :set paste<CR>A

map <Leader>v <C-v>

" Autoexpand matching characters
inoremap (<CR> (<CR>)<Esc>O
inoremap {<CR> {<CR>}<Esc>O
inoremap {; {<CR>};<Esc>O
inoremap {, {<CR>},<Esc>O
inoremap [<CR> [<CR>]<Esc>O
inoremap [; [<CR>];<Esc>O
inoremap [, [<CR>],<Esc>O

" for when you forget to sudo vim
command! W w !sudo tee % > /dev/null

" Because I can't control my shifting
cabbrev B b

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

" Add .vimlocal to the runtimepath for local-specific configs
set runtimepath^=~/.vimlocal

runtime vimrclocal.vim

"color borland           " set color scheme
set background=dark
set t_Co=16
let g:solarized_termcolors = 16
let g:solarized_bold = 0
let g:solarized_italic = 0
colorscheme solarized

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" mark trailing spaces as an error
highlight InvalidWhitespace ctermbg=red guibg=red
match InvalidWhitespace  /\s\+$/

" mixed spaces and tabs is error
"syntax match Error / \+\t/ containedin=ALL
2match InvalidWhitespace  / \+\t *\| *\t \+/

" Highlight the column just over textwidth
highlight ColorColumn ctermbg=0
set colorcolumn=+2

function! ToggleHLSearch()
  if &hls
    set nohlsearch
  else
    set hlsearch
  endif
endfunction
nmap <silent> <C-n> <Esc>:call ToggleHLSearch()<CR>

" path for find commands (cwd + projects dir + pear)
" set path+=.,/home/gim/projects/**

" vim-sleuth should make these unnecessary
set shiftwidth=2
set tabstop=8
if v:version >= 704
  setlocal softtabstop=-1
else
  setlocal softtabstop=2
endif
set expandtab
"set textwidth=80
set cino=>1s,n-1s,:1s,=1s,(2s,+2s
set cink=0{,0},:,!^F,!<Tab>,o,O,e


function! s:MaybeRepoRoot ()
  " Try git first
  let root=system("git root")
  if v:shell_error != 0
    " Try svn?
    let root=system("svn info | grep -oP '^Working Copy Root Path: \\K.*$'")
  endif
  if v:shell_error == 0
    execute "setlocal path+=" . fnameescape(root[:-2]) . "'/**"
  endif
endfunction

if has("autocmd")
  augroup Vimrc
    "remove ALL autocommands for the current group
    autocmd!

    autocmd BufEnter * :syntax sync fromstart " ensure full syntax hilighting

    " underline current line in insert mode
    autocmd InsertLeave * se nocul nopaste
    autocmd InsertEnter * se cul

    " " Disable the C-C commenting and resote expected behavior in the cmdwin
    " autocmd CmdwinEnter * noremap <buffer> <C-C> <C-C>

    " Surely there's a better way...
    " " svn commits
    " autocmd BufNewFile,BufRead  svn-commit.* setf svn
    " autocmd FileType svn map <Leader>sd :SVNCommitDiff<CR>
    " let SVNCommandEnableBufferSetup=1
    " let SVNCommandCommitOnWrite=1
    " let SVNCommandEdit='split'
    " let SVNCommandNameResultBuffers=1

    " don't expand tabs to spaces in makefiles
    autocmd BufNewFile,BufRead [Mm]akefile* setlocal noet

    autocmd BufNewFile,BufRead * call s:MaybeRepoRoot()

  augroup END

  " Do I actually even use this stuff??
  " augroup JumpCursorOnEdit
  "   "remove ALL autocommands for the current group
  "   autocmd!

  "   autocmd BufReadPost *
  "         \ if expand("<afile>:p:h") !=? $TEMP |
  "         \   if line("'\"") > 1 && line("'\"") <= line("$") |
  "         \     let JumpCursorOnEdit_foo = line("'\"") |
  "         \     let b:doopenfold = 1 |
  "         \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
  "         \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
  "         \        let b:doopenfold = 2 |
  "         \     endif |
  "         \     exe JumpCursorOnEdit_foo |
  "         \   endif |
  "         \ endif
  "   " Need to postpone using "zv" until after reading the modelines.
  "   autocmd BufWinEnter *
  "         \ if exists("b:doopenfold") |
  "         \   exe "normal! zv" |
  "         \   if(b:doopenfold > 1) |
  "         \       exe  "+".1 |
  "         \   endif |
  "         \   unlet b:doopenfold |
  "         \ endif
  " augroup END

  " This is maybe more annoying than helpful
  "augroup VimConfig
  "  autocmd!
  "  autocmd BufWritePost ~/.vimrc source ~/.vimrc
  "  autocmd BufWritePost vimrc    source ~/.vimrc
  "augroup END

endif

" Term sequences
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

set t_RV=
let g:sparkupNextMapping = '<c-l>'


" vim -b : edit binary using xxd-format!
augroup Binary
  autocmd!
  autocmd BufReadPre  *.bin set binary
  autocmd BufReadPost *.bin
    \ if &binary
    \ |   execute "silent %!xxd -c 32"
    \ |   set filetype=xxd
    \ |   redraw
    \ | endif
  autocmd BufWritePre *.bin
    \ if &binary
    \ |   let s:view = winsaveview()
    \ |   execute "silent %!xxd -r -c 32"
    \ | endif
  autocmd BufWritePost *.bin
    \ if &binary
    \ |   execute "silent %!xxd -c 32"
    \ |   set nomodified
    \ |   call winrestview(s:view)
    \ |   redraw
    \ | endif
augroup END

  " vim: set sw=2 ts=2 sts=2 et :
