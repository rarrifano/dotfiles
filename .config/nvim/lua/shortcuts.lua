-- Clipboard
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>p', '"+p')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>P', '"+P')
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set('v', '<leader>P', '"+P')
vim.keymap.set('v', '<leader>Y', '"+Y')

-- Windows shortcuts
vim.keymap.set('n', '<A-h>', '<cmd>wincmd h<CR>')
vim.keymap.set('n', '<A-j>', '<cmd>wincmd j<CR>')
vim.keymap.set('n', '<A-k>', '<cmd>wincmd k<CR>')
vim.keymap.set('n', '<A-l>', '<cmd>wincmd l<CR>')
vim.keymap.set('n', '<C-j>', '<cmd>bnext<CR>')
vim.keymap.set('n', '<C-k>', '<cmd>bprev<CR>')

-- Netrw
vim.keymap.set('n', '<leader>;', '<cmd>Vex ~/.config/nvim<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>Ex<CR>')
