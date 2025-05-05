set termguicolors
set encoding=utf-8
set nobackup
set noswapfile
set undofile
set hidden

set number
set relativenumber
set laststatus=1
set nowrap
set scrolloff=4
set showmatch
set showcmd
set wildmenu
set wildmode=list:longest
set nohlsearch
set incsearch
set ignorecase
set smartcase

set expandtab
set smartindent
set autoindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set backspace=indent,eol,start
set splitbelow
set splitright
set mouse=

set timeout
set timeoutlen=1000
set ttimeoutlen=0
set updatetime=300

set autoread
set history=1000
set undolevels=1000
set title
set ttyfast
set shortmess+=c
set complete-=i
set nrformats-=octal
set display+=lastline
set formatoptions+=j
set lazyredraw

let mapleader=" "

nnoremap <leader>p "+p
nnoremap <leader>y "+y
vnoremap <leader>p "+p
vnoremap <leader>y "+y
nnoremap <leader>P "+P
nnoremap <leader>Y "+Y
vnoremap <leader>P "+P
vnoremap <leader>Y "+Y

nnoremap h :wincmd h<CR>
nnoremap j :wincmd j<CR>
nnoremap k :wincmd k<CR>
nnoremap l :wincmd l<CR>

nnoremap <C-j> :bnext<CR>
nnoremap <C-k> :bprev<CR>

autocmd BufNewFile,BufRead Dockerfile* set filetype=dockerfile
autocmd BufNewFile,BufRead docker-compose*.{yaml,yml} set filetype=yaml
autocmd BufNewFile,BufRead *.{tf,tfvars} set filetype=terraform
autocmd BufNewFile,BufRead *.hcl set filetype=hcl
autocmd BufNewFile,BufRead *.{yaml,yml} set filetype=yaml
autocmd BufNewFile,BufRead inventory set filetype=ansible_hosts
autocmd BufNewFile,BufRead playbook*.{yaml,yml} set filetype=ansible
autocmd BufNewFile,BufRead *.{yaml,yml} if search('apiVersion:', 'n') | set filetype=yaml.kubernetes | endif

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:> foldmethod=indent nofoldenable
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType terraform setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType dockerfile setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType go setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab

syntax on
set background=dark
if filereadable(expand("~/.vim/colors/gruvbox.vim"))
  colorscheme gruvbox
else
  colorscheme desert
endif
