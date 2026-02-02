-- Oil file browser
return {
    'stevearc/oil.nvim',
    keys = {
        { '-', function() require('oil').open() end, desc = 'Open file browser' },
    },
    opts = {},
}
