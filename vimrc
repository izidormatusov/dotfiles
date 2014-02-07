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

" I love many tabs
set tabpagemax=999

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
set listchars=tab:>\ ,trail:✗,extends:▶,precedes:◀,nbsp:☢

" Toggle paste mode
set pastetoggle=<F2>

" Time to learn to live with mouse
set mouse=a

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

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

" Show up to 10 files
let g:CommandTMaxHeight=10
set wildignore=*.pyc,*.jpeg,*.png

" Easily search codebases
map <Leader>o :CommandT ~/workspace/oscar/<CR>
map <Leader>d :CommandT ~/workspace/django/django/<CR>
map <Leader>al :CommandT ~/workspace/asset-library/<CR>
map <Leader>b :CommandT ~/workspace/blakey/<CR>

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

if has('autocmd')
    autocmd FileType make call MakfileSetting()
    autocmd FileType python call PythonSettings()
    autocmd FileType gitcommit setlocal nolist

    " Treat .rss files as XML
    " autocmd BufNewFile,BufRead *.rss setfiletype xml
endif
