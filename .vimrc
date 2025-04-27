set termguicolors
set nobackup
set expandtab
set hidden
set nohlsearch
set laststatus=1
set number
set relativenumber
set shiftwidth=2
set softtabstop=2
set tabstop=2
set splitbelow
set splitright
set noswapfile
set undofile
set nowrap
set smartindent
set autoindent
set scrolloff=4
set encoding=utf-8
set showmatch
set incsearch
set ignorecase
set smartcase
set clipboard=unnamed
set backspace=indent,eol,start
set history=1000
set undolevels=1000
set wildmenu
set wildmode=list:longest
set showcmd
set mouse=
set timeout
set timeoutlen=1000
set ttimeoutlen=0
set updatetime=300

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

autocmd BufNewFile,BufRead Dockerfile* set syntax=dockerfile
autocmd BufNewFile,BufRead docker-compose*.{yaml,yml} set syntax=yaml
autocmd BufNewFile,BufRead *.{tf,tfvars} set syntax=terraform
autocmd BufNewFile,BufRead *.hcl set syntax=hcl
autocmd BufNewFile,BufRead *.{yaml,yml} set syntax=yaml
autocmd BufNewFile,BufRead inventory set syntax=ansible_hosts
autocmd BufNewFile,BufRead playbook*.{yaml,yml} set syntax=ansible
autocmd BufNewFile,BufRead *.{yaml,yml} if search('apiVersion:', 'n') | set syntax=yaml.kubernetes | endif

autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType terraform setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType dockerfile setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType go setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab

set background=dark
colorscheme gruvbox
syntax on
