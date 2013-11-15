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

" Prefer spaces
" You want to keep those settings set to the same value:
" http://vimcasts.org/episodes/tabs-and-spaces/
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Take care of whitespace characters
set list
set listchars=tab:>\ ,trail:~,extends:>,precedes:<,nbsp:.

" Toggle paste mode
set pastetoggle=<F2>

" Time to learn to live with mouse
set mouse=a

" change the mapleader from \ to ,
let mapleader=","

" Wombat colorscheme
set t_Co=256
colorscheme wombat256

" Pathogen
execute pathogen#infect()

" Sudo saving
cmap w!! w !sudo tee % >/dev/null

function! MakfileSetting()
    " Makefile requires tabs
    set noexpandtab
endfunction

function! PythonSettings()
    " Red line for 80 character limit
    set colorcolumn=80
endfunction

if has('autocmd')
    autocmd FileType make call MakfileSetting()
    autocmd FileType python call PythonSettings()
endif
