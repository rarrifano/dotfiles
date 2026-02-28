-- Treesitter syntax highlighting
return {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    opts = {
        ensure_installed = {
            'bash',
            'dockerfile',
            'hcl',
            'helm',
            'json',
            'jsonc',
            'lua',
            'markdown',
            'markdown_inline',
            'python',
            'terraform',
            'toml',
            'vimdoc',
            'yaml',
        },
        highlight = { enable = true },
        indent = { enable = true },
    },
}
