-- Treesitter syntax highlighting
return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = { 'terraform', 'python', 'bash', 'dockerfile', 'yaml', 'json', 'markdown', 'lua' },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
