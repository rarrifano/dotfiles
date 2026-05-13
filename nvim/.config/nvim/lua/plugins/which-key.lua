-- Discoverable keybindings without emojis
return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
        preset = 'modern',
        delay = 300,
        icons = {
            mappings = false, -- Disable icons for all mappings
            breadcrumb = ' ',
            separator = ' -> ',
            group = '',
        },
        show_help = false,
        spec = {
            { '<leader>b', group = 'buffer' },
            { '<leader>c', group = 'code' },
            { '<leader>d', group = 'debug' },
            { '<leader>f', group = 'find' },
            { '<leader>g', group = 'git' },
            { '<leader>h', group = 'hunk' },
        },
    },
}
