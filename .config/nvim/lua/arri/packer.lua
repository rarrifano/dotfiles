-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'
    use 'ellisonleao/gruvbox.nvim'
    use 'tpope/vim-fugitive'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"

    use {
        'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'
    }

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

end)
