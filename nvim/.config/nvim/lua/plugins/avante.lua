-- Avante - AI inline commands
return {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    build = 'make',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'stevearc/dressing.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
    },
    opts = {
        provider = 'copilot',
        providers = {
            copilot = {
                model = 'gpt-4o',
            },
        },
        mappings = {
            edit = '<C-k>',
        },
    },
}
