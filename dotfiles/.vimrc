" {{{
" References:
"  https://learnvimscriptthehardway.stevelosh.com/
"  http://vimcasts.org/
" }}}

" Essential configuration {{{
set nocompatible

syntax on
filetype plugin indent on

" If adding an extra line with no content, delete the spaces
set autoindent

" Show parts of the commands
set showcmd

" Disable the line numbers to make vim a bit faster
" You can always reach given line from an error message by pressing <num>G
set nonumber

" Allow backspace to delete stuff before the start of the current insert
set backspace=indent,eol,start

" Allow modified files in the background, making easy to switch between files
set hidden

" Ignore mouse in terminal
set mouse=

" Emulate bash autocompletion behavior
set wildmenu
set wildmode=list:longest

" Allow opening as many tabs as you might want
set tabpagemax=999999

" Always show the file path
set laststatus=2

let mapleader=" "

" Turn off audio bell.
set belloff=all
" }}}

" GUI Options {{{
if has("gui_running")
  set mouse=a
  " a - autoselect and copy into the clipboard
  " T - show the toolbar
  " r - right hand scrollbar
  " L - left hand scrollbar
  " k - keep the size of the window same even when adding tab bar
  " e - use GUI tabs instead of text-render
  set guioptions-=aTrL
  set guioptions+=ek
  "
  set guifont=JetBrainsMono\ Nerd\ Font\ Mono:h13
endif
" }}}

" Temporary files {{{
" Raise an error if one of the temp folders does not exist
function! CheckDirectoriesExist(dirs)
  for dir in split(a:dirs, ',')
    call mkdir(dir, "p")
  endfor
endfunction

" swap files
set directory=~/.vimtemp/swap
call CheckDirectoriesExist(&directory)

" Persistent undo {{{
if has('persistent_undo')
  set undofile
  set undodir=~/.vimtemp/undo
  call CheckDirectoriesExist(&undodir)
  " maximum number of changes that can be undone
  set undolevels=1000
  " maximum number lines to save for undo on a buffer reload
  set undoreload=10000
endif
" }}}
" }}}

" Search {{{
set incsearch
set hlsearch
set ignorecase
set smartcase
" }}}

" Take care of whitespace characters {{{
set list
set listchars=tab:>\ ,trail:·,extends:▶,precedes:◀,nbsp:☢
" Soft wrap
set showbreak=…
" }}}

" Prefer spaces over tabs {{{
" You want to keep those settings set to the same value:
" http://vimcasts.org/episodes/tabs-and-spaces/
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" }}}

" Colorschemes {{{

" Use 256 colors
set t_Co=256

" Fallback theme from default
silent! colorscheme habamax

" Load lucius if it exists
let g:lucius_style='dark'
let g:lucius_contrast='normal'
let g:lucius_contrast_bg='high'
let g:lucius_no_term_bg=1
silent! colorscheme lucius
" }}}

" tmux integration {{{
function! TmuxRestartWorkflow()
  python3 << EOF
import subprocess
pane_index = 1
panes = subprocess.check_output(
  ['tmux', 'list-panes', '-F', '#{pane_index} #{pane_current_command}'])
lines = [line.split(' ', 1)[1] for line in panes.decode().strip().splitlines()
         if line.startswith('%d ' % pane_index)]
assert len(lines) == 1, "There are %d panes" % len(lines)
command = lines[0]

keys = ['C-p', 'C-j']
if command != "bash":
  keys.insert(0, 'C-c')
subprocess.check_call(['tmux', 'send-keys', '-t', '.%d' % pane_index] + keys)
EOF
endfunction

function! TmuxSendBuffer()
  python3 << EOF
import subprocess
content = '\n'.join(vim.current.buffer[:]) + '\n'
subprocess.check_call(['tmux', 'send-keys', '-t', '{last}', content])
EOF
endfunction

nnoremap <leader>t :write<cr>:call TmuxRestartWorkflow()<cr>
nnoremap <F5> :write<cr>:call TmuxRestartWorkflow()<cr>
inoremap <F5> <esc>:write<cr>:call TmuxRestartWorkflow()<cr>
nnoremap <F4> :call TmuxSendBuffer()<cr>
" }}}

" Folding {{{
" By default rely on syntax for folding
" You can limit the maximum number of folds by setting foldnestmax
if get(s:, 'vimrc_already_folded', 0) == 0
  set foldmethod=syntax
  " Start with all folds opened
  set foldlevel=99
  " Command skipping such as { should not open fold
  set foldopen-=block
  " Prevent folding update when editing .vimrc
  let s:already_folder = 1
endif
" }}}

" File type preferences {{{
" Highlight the end of the line.
" Multiple columns with absolute numbers: colorcolumn=60,80,100
" Multiple relative columns to textwidth: colorcolumn=+0,+10+20
set colorcolumn=80
" Highlight the current line
" set cursorline

" Allow spelling everywhere
set spell spelllang=en

augroup filetype_settings
  autocmd!

  " Makefiles use tabs
  autocmd FileType make
        \ setlocal noexpandtab tabstop=4 softtabstop=4 shiftwidth=4

  autocmd FileType python
        \ setlocal nowrap expandtab

  autocmd FileType vim
        \ setlocal foldmethod=marker foldlevel=0

  " Some Java/C++ files can get very large and vim with folding gets sluggish
  " Thus disabling foldmethod=syntax
  autocmd FileType java
        \ setlocal textwidth=100 colorcolumn=+0 foldmethod=manual

  autocmd FileType cpp
        \ setlocal foldmethod=manual

  autocmd FileType go
        \ setlocal listchars+=tab:\ \ 

  " Go uses tabs and has not width limit
  autocmd FileType go
        \ setlocal noexpandtab tabstop=4 softtabstop=4 shiftwidth=4

  autocmd Filetype markdown
        \ setlocal textwidth=80 colorcolumn=+0

  " Autosave markdown files after switching to another window
  autocmd FocusLost *.md write

  " Automatically fold bashrc configuration
  autocmd BufRead,BufNewFile .bash*
        \ setlocal foldmethod=marker foldlevel=0

  autocmd Filetype sh
        \ setlocal formatprg=formatshell

  " After saving ~/.vimrc, source the changes
  autocmd BufWritePost $MYVIMRC source $MYVIMRC

  " Disable backups on temporary files
  " Inspired by https://git.zx2c4.com/password-store/tree/contrib/vim/redact_pass.vim
  autocmd VimEnter /tmp/*,$TMPDIR/*,/private/var/*
        \ setlocal nobackup nowritebackup noswapfile noundofile viminfo=

  autocmd BufNewFile,BufRead /private/var/folders/**/pass.*/*.txt
        \ set filetype=pass

augroup END
" }}}

" FZF configuration {{{
" References:
"  https://github.com/junegunn/fzf/blob/master/README-VIM.md
"  https://github.com/junegunn/fzf.vim

if isdirectory("/opt/homebrew/opt/fzf")
  set runtimepath+=/opt/homebrew/opt/fzf
  let s:has_fzf=1
elseif filereadable("/usr/share/doc/fzf/examples/fzf.vim")
  source /usr/share/doc/fzf/examples/fzf.vim
  let s:has_fzf=1
endif

if exists("s:has_fzf")
  " You can confirm FZF with the following commands to open it in new
  " tab/split etc
  let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }

  " Enable per-command history (CTRL-N/CTRL-P will select next/previous queries)
  let g:fzf_history_dir = '~/.local/share/fzf-history'

  nnoremap <leader>p :<c-u>FZF<cr>
endif
" }}}

" See https://superuser.com/a/1062063
let g:netrw_altv=1

if filereadable(expand("~/.work.vim"))
  source ~/.work.vim
endif
