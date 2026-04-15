-- Seamless navigation between nvim splits and tmux panes
return {
    'numToStr/Navigator.nvim',
    lazy = false,
    opts = {
        auto_save = nil,
        disable_on_zoom = false,
    },
    config = function(_, opts)
        require('Navigator').setup(opts)

        local map = vim.keymap.set
        local nav = require('Navigator')

        map({ 'n', 't' }, '<A-h>', nav.left,  { desc = 'Navigate left (nvim/tmux)' })
        map({ 'n', 't' }, '<A-j>', nav.down,  { desc = 'Navigate down (nvim/tmux)' })
        map({ 'n', 't' }, '<A-k>', nav.up,    { desc = 'Navigate up (nvim/tmux)' })
        map({ 'n', 't' }, '<A-l>', nav.right, { desc = 'Navigate right (nvim/tmux)' })
    end,
}
