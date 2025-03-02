vim.keymap.set('n', '<leader>p', '"+p', { silent = true })
vim.keymap.set('n', '<leader>y', '"+y', { silent = true })
vim.keymap.set('v', '<leader>p', '"+p', { silent = true })
vim.keymap.set('v', '<leader>y', '"+y', { silent = true })

vim.keymap.set('n', '<M-h>', ':wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<M-j>', ':wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<M-k>', ':wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<M-l>', ':wincmd l<CR>', { silent = true })

vim.keymap.set('t', '<ESC>', [[<C-\><C-n>]], { silent = true })
