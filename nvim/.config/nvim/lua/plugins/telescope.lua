-- Telescope fuzzy finder
return {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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
        telescope.load_extension('fzf')
    end,
}
