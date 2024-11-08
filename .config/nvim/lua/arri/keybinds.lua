vim.keymap.set('n', '<leader>ee', ':Ex<CR>', { silent = true })
vim.keymap.set('n', '<leader>op', ':e $MYVIMRC<CR>', { silent = true })
vim.keymap.set('n', '<leader>oi', ':e ~/.bashrc<CR>', { silent = true })

vim.keymap.set('n', '<leader>s', ':wincmd s<CR>', { silent = true })
vim.keymap.set('n', '<leader>v', ':wincmd v<CR>', { silent = true })
vim.keymap.set('n', '<leader>n', ':bNext<CR>', { silent = true })

vim.keymap.set('n', '<leader>p', '"+p', { silent = true })
vim.keymap.set('n', '<leader>y', '"+y', { silent = true })
vim.keymap.set('v', '<leader>p', '"+p', { silent = true })
vim.keymap.set('v', '<leader>y', '"+y', { silent = true })

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { silent = true })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', { silent = true })

vim.keymap.set('n', '<leader>q', ':exe "e ~/Documentos/".strftime("%y%m%d%k%M%S.md")<CR>', { silent = true })

vim.keymap.set('n', '<M-h>', '<CMD>NavigatorLeft<CR>', { silent = true })
vim.keymap.set('n', '<M-j>', '<CMD>NavigatorDown<CR>', { silent = true })
vim.keymap.set('n', '<M-k>', '<CMD>NavigatorUp<CR>', { silent = true })
vim.keymap.set('n', '<M-l>', '<CMD>NavigatorRight<CR>', { silent = true })
