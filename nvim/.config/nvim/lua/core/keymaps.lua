-- Leader
vim.g.mapleader = ' '

-- Quick panel navigation with Alt-hjkl
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true })

-- Canonical Telescope keymaps
vim.keymap.set('n', '<leader>f', "<cmd>Telescope find_files<CR>", { desc = 'Find Files (Telescope)', noremap = true })
vim.keymap.set('n', '<leader>/', "<cmd>Telescope live_grep<CR>", { desc = 'Grep Project (Telescope)', noremap = true })
vim.keymap.set('n', '<leader><leader>', "<cmd>Telescope buffers<CR>", { desc = 'List Buffers (Telescope)', noremap = true })
vim.keymap.set('n', '<leader>:', "<cmd>Telescope commands<CR>", { desc = 'List Commands (Telescope)', noremap = true })

-- Useful Telescope: diagnostics, LSP mappings
vim.keymap.set('n', '<leader>d', "<cmd>Telescope diagnostics<CR>", { desc = 'Diagnostics (Telescope)', noremap = true })
vim.keymap.set('n', 'gr', "<cmd>Telescope lsp_references<CR>", { desc = 'LSP References (Telescope)', noremap = true })
vim.keymap.set('n', 'gi', "<cmd>Telescope lsp_implementations<CR>", { desc = 'LSP Implementations (Telescope)', noremap = true })
vim.keymap.set('n', 'gd', "<cmd>Telescope lsp_definitions<CR>", { desc = 'LSP Definitions (Telescope)', noremap = true })
vim.keymap.set('n', 'gt', "<cmd>Telescope lsp_type_definitions<CR>", { desc = 'LSP Type Definitions (Telescope)', noremap = true })

-- Git + Telescope + Fugitive ergonomics
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Git Status (Telescope + Fugitive)', noremap = true })
vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { desc = 'Git Branches (Telescope + Fugitive)', noremap = true })
vim.keymap.set('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', { desc = 'Git Commits (Telescope + Fugitive)', noremap = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<CR>', { desc = 'Fugitive DiffSplit', noremap = true })
vim.keymap.set('n', '<leader>gl', '<cmd>G log --oneline --decorate --graph<CR>', { desc = 'Fugitive Log (inline)', noremap = true })

-- System clipboard copy/paste
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { noremap = true, desc = 'Yank to system clipboard' })
vim.keymap.set({'n'}, '<leader>Y', '"+Y', { noremap = true, desc = 'Yank line to system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { noremap = true, desc = 'Paste from system clipboard' })
vim.keymap.set({'n'}, '<leader>P', '"+P', { noremap = true, desc = 'Paste before from system clipboard' })
