-- Telescope fuzzy finder
return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
        local telescope = require('telescope')
        telescope.setup({
            defaults = {
                file_ignore_patterns = {
                    'node_modules', '.git/', '.terraform', '.venv',
                    'target/', '.cache/', 'vendor/', 'dist/', '.DS_Store$', '%.pyc$',
                },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        })
        telescope.load_extension('ui-select')
    end,
}
