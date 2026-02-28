-- Treesitter syntax highlighting
return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    opts = {
        ensure_installed = { 'terraform', 'python', 'bash', 'dockerfile', 'yaml', 'json', 'markdown', 'lua' },
        highlight = { enable = true },
        indent = { enable = true },
    },
}
