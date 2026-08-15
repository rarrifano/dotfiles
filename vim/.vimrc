set number
set relativenumber
let mapleader = " "
set ignorecase
set smartcase
set tabstop=4
set shiftwidth=4
set expandtab
set splitbelow
set splitright

syntax on
filetype plugin indent on
set background=dark
colorscheme retrobox

autocmd FileType yaml,yml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType terraform,hcl setlocal tabstop=2 shiftwidth=2 expandtab

if isdirectory("/usr/share/doc/fzf/examples")
  set rtp+=/usr/share/doc/fzf/examples
  nnoremap <C-p> :FZF<CR>
endif

nnoremap <leader>y "+y
vnoremap <leader>y "+y

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
