set number
set relativenumber
set ignorecase
set smartcase
set tabstop=4
set shiftwidth=4
set expandtab
set splitbelow
set splitright

syntax on
filetype plugin indent on

autocmd FileType yaml,yml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType terraform,hcl setlocal tabstop=2 shiftwidth=2 expandtab

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
