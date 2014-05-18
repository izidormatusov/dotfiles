" No, I don't need backward compatibility
set nocompatible
set backspace=indent,eol,start

syntax on
filetype plugin indent on

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Indentation
set autoindent

" Show keys as typed in
set showcmd

" Prefer spaces
" You want to keep those settings set to the same value:
" http://vimcasts.org/episodes/tabs-and-spaces/
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Take care of whitespace characters
set list
set listchars=tab:>\ ,trail:·,extends:▶,precedes:◀,nbsp:☢
" Soft wrap
:set showbreak=…

" Toggle paste mode
set pastetoggle=<F2>

" Time to learn to live with mouse
set mouse=a

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

" "Refocus" folds
nnoremap ,z zMzvzz

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO

" change the mapleader from \ to ,
let mapleader=","

" Pathogen
execute pathogen#infect()

" Wombat colorscheme
set t_Co=256
" colorscheme wombat256
let g:lucius_style='dark'
let g:lucius_contrast='normal'
colorscheme lucius

" Sudo saving
cmap w!! w !sudo tee % >/dev/null

set wildignore=*.pyc,*.jpeg,*.png

" Easily search codebases
map <Leader>o :CtrlP ~/workspace/oscar/<CR>
map <Leader>d :CtrlP ~/workspace/django/django/<CR>
map <Leader>b :CtrlP ~/workspace/blakey/<CR>
map <Leader>n :CtrlP ~/files/<CR>

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g "" | sort'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
    let g:ctrlp_user_command = 'find %s -type f | sort'
endif

" :Ag command
command -nargs=+ -complete=file -bar Ag silent grep <args>|cwindow|redraw!
command -nargs=+ -complete=file -bar AgArgs args `ag --nocolor -l <args>`
nnoremap K *:grep "\b<C-R><C-W>\b"<CR>:cwindow<CR>

" Expand %%/ into a directory
cabbr <expr> %% expand('%:p:h')

" Allow project specific vimrc
set exrc
set secure

" Allow buffer jumping
set hidden

" Edit current snippet filetype
map <Leader>s :execute 'tabe ~/.vim/bundle/snipmate/snippets/' . &filetype . '.snippets'<CR>

" Job log
map <Leader>j :edit ~/files/journal/job.log<CR>:setlocal textwidth=80<CR>
map <F3> Go<CR><ESC>:r! date "+\%Y-\%m-\%d (\%A) \%H:\%M @ `hostname`"<CR>o

function! MakfileSetting()
    " Makefile requires tabs
    setlocal noexpandtab
endfunction

function! PythonSettings()
    " Red line for 80 character limit
    setlocal colorcolumn=80

    " Punish me for long lines!
    setlocal nowrap

    " Format python
    setlocal formatprg=autopep8\ -aa\ -

    map <C-F12> :!ctags -R .<CR>
    set tags+=~/workspace/django/tags
    set tags+=~/workspace/oscar/tags
    set tags+=~/workspace/blakey/tags
endfunction

function! SQLSettings()
    setlocal formatprg=sqlformat\ --keywords=upper\ -r\ -
endfunction

function! YamlSettings()
    set tabstop=2 softtabstop=2 shiftwidth=2
endfunction

if has('autocmd')
    autocmd FileType make call MakfileSetting()
    autocmd FileType python call PythonSettings()
    autocmd FileType sql call SQLSettings()
    autocmd FileType gitcommit setlocal nolist
    autocmd FileType mkd setlocal foldlevel=1
    autocmd FileType yaml call YamlSettings()
endif


if has('persistent_undo')
    set undodir=~/.vim/undodir
    set undofile
    " maximum number of changes that can be undone
    set undolevels=1000
    " maximum number lines to save for undo on a buffer reload
    set undoreload=10000
endif

" Remove toolbar
set guioptions-=T
" Remove scrollbars
set guioptions-=r
