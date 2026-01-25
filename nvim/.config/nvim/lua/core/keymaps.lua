-- Leader
vim.g.mapleader = ' '

-- Quick panel navigation with Alt-hjkl
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })


-- Git (g = Git, <leader>gX)
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Git Status', noremap = true })
vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { desc = 'Git Branches', noremap = true })
vim.keymap.set('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', { desc = 'Git Commits', noremap = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<CR>', { desc = 'Git DiffSplit (Fugitive)', noremap = true })
vim.keymap.set('n', '<leader>gl', '<cmd>G log --oneline --decorate --graph<CR>', { desc = 'Git Log', noremap = true })

-- Telescope (t = Telescope, <leader>tX)
vim.keymap.set('n', '<leader>f', '<cmd>Telescope find_files<CR>', { desc = 'Telescope Find Files', noremap = true })
vim.keymap.set('n', '<leader>/', '<cmd>Telescope live_grep<CR>', { desc = 'Telescope Grep Project', noremap = true })
vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope buffers<CR>', { desc = 'Telescope List Buffers', noremap = true })
vim.keymap.set('n', '<leader>c', '<cmd>Telescope commands<CR>', { desc = 'Telescope List Commands', noremap = true })

-- LSP (l = LSP, <leader>lX)
vim.keymap.set('n', '<leader>e', '<cmd>Telescope diagnostics<CR>', { desc = 'LSP Diagnostics', noremap = true })
vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<CR>', { desc = 'LSP References', noremap = true })
vim.keymap.set('n', '<leader>gi', '<cmd>Telescope lsp_implementations<CR>', { desc = 'LSP Implementations', noremap = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Telescope lsp_definitions<CR>', { desc = 'LSP Definitions', noremap = true })
vim.keymap.set('n', '<leader>gt', '<cmd>Telescope lsp_type_definitions<CR>', { desc = 'LSP Type Definitions', noremap = true })

-- Clipboard (c = Clipboard, <leader>cX)
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { noremap = true, desc = 'Yank to system clipboard' })
vim.keymap.set({'n'}, '<leader>Y', '"+Y', { noremap = true, desc = 'Yank line to system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { noremap = true, desc = 'Paste from system clipboard' })
vim.keymap.set({'n'}, '<leader>P', '"+P', { noremap = true, desc = 'Paste before from system clipboard' })

-- LSP Diagnostics navigation and display
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to prev diagnostic', noremap = true })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic', noremap = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show line diagnostics', noremap = true })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list', noremap = true })
