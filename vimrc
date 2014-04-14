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
set listchars=tab:>\ ,trail:✗,extends:▶,precedes:◀,nbsp:☢

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

" Wombat colorscheme
set t_Co=256
colorscheme wombat256

" Pathogen
execute pathogen#infect()

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
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

else
    let g:ctrlp_user_command = 'find %s -type f'
endif

" :Ag command
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Expand %%/ into a directory
cabbr <expr> %% expand('%:p:h')

" Allow project specific vimrc
set exrc
set secure

" Allow buffer jumping
set hidden

" Edit current snippet filetype
map <Leader>s :execute 'tabe ~/.vim/bundle/snipmate/snippets/' . &filetype . '.snippets'<CR>

function! MakfileSetting()
    " Makefile requires tabs
    setlocal noexpandtab
endfunction

function! PythonSettings()
    " Red line for 80 character limit
    setlocal colorcolumn=80
endfunction

function! YamlSettings()
    set tabstop=2 softtabstop=2 shiftwidth=2
endfunction

if has('autocmd')
    autocmd FileType make call MakfileSetting()
    autocmd FileType python call PythonSettings()
    autocmd FileType gitcommit setlocal nolist
    autocmd FileType mkd setlocal foldlevel=1
    autocmd FileType yaml call YamlSettings()
endif
