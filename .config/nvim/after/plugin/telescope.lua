local builtin = require('telescope.builtin')

-- Files
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('v', 'F', builtin.grep_string, { desc = 'Telescope grep string' })

-- Settings
vim.keymap.set('n', '<leader>,', function() builtin.find_files({cwd = '~/.config/nvim'}) end, { desc = 'Settings find files' })

-- Buffers
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })

-- Docs
vim.keymap.set('n', '<leader>k', builtin.help_tags, { desc = 'Telescope help tags' })
