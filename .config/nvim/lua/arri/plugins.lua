local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug ('airblade/vim-gitgutter')
Plug ('christoomey/vim-tmux-navigator')
Plug ('nvim-lua/plenary.nvim')
Plug ('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
Plug ('nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.7.2' })
Plug ('sainnhe/gruvbox-material')
Plug ('tpope/vim-fugitive')
Plug ('tpope/vim-sensible')
Plug ('tpope/vim-surround')

vim.call('plug#end')

vim.cmd('colorscheme gruvbox-material')

require'nvim-treesitter.configs'.setup { highlight = { enable = true } }
