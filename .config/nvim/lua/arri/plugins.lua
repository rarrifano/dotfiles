local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug ('morhetz/gruvbox')
Plug ('christoomey/vim-tmux-navigator')
Plug ('nvim-lua/plenary.nvim')
Plug ('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
Plug ('nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.7.2' })

vim.call('plug#end')

vim.cmd('colorscheme gruvbox')
require'nvim-treesitter.configs'.setup { highlight = { enable = true } }
