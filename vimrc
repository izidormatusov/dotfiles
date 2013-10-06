" Some good sources of inspiration:
" - http://people.ksp.sk/~misof/programy/vimrc.html

" Standard
set nocompatible
set history=50
set ruler
syntax on

" when opening a file, use only current directory or directory of file
set path=,

set hlsearch
highlight Normal guibg=#fffff2
set smartindent
set tabpagemax=300

" autosave before :make
set autowrite

set wildmode=longest,full
set wildmenu

" connect vim clipboard with system-wide
set clipboard+=unnamed

" Search
set incsearch
set ignorecase
set smartcase

" Show match )}]
set showmatch

" Tabs vs spaces
set shiftwidth=4
set softtabstop=4
set expandtab
set modeline

filetype on
filetype plugin on
filetype plugin indent on

" vala
autocmd BufRead *.vala,*.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala,*.vapi setfiletype vala

so ~/.vim/skeletons.vim


" Highlight chars over 80 chars
set colorcolumn=80
set nocompatible
call pathogen#infect() 

" Wombat colorscheme
set t_Co=256
colorscheme wombat256

" Toggle paste mode
set pastetoggle=<F2>

" change the mapleader from \ to ,
let mapleader=","
" Nerd Tree
map <F3> :NERDTreeToggle<CR>

" CTags support
" See http://amix.dk/blog/post/19329
let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_WinWidth = 50
map <F4> :TlistToggle<cr>
"map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" See http://andrewradev.com/2011/06/08/vim-and-ctags/
autocmd BufWritePost *
      \ if filereadable('tags') |
      \   call system('ctags -R '.expand('%')) |
      \ endif

" Disable folding for markdown
let g:vim_markdown_folding_disabled=1

" Support for ledger
autocmd BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger
