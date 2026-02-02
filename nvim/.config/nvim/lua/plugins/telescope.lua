-- Telescope fuzzy finder
return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        defaults = {
            file_ignore_patterns = {
                'node_modules', '.git/', '.terraform', '.venv',
                'target/', '.cache/', 'vendor/', 'dist/', '.DS_Store$', '%.pyc$',
            },
        },
    },
}
