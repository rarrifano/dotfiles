local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug ('airblade/vim-gitgutter')
Plug ('numToStr/Navigator.nvim')
Plug ('nvim-lua/plenary.nvim')
Plug ('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
Plug ('sainnhe/gruvbox-material')
Plug ('tpope/vim-fugitive')
Plug ('tpope/vim-sensible')
Plug ('sheerun/vim-polyglot')

vim.call('plug#end')

vim.cmd('colorscheme gruvbox-material')

require('Navigator').setup()
