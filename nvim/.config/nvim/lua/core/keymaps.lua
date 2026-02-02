-- Keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window navigation with Alt+hjkl
map('n', '<A-h>', '<C-w>h', opts)
map('n', '<A-j>', '<C-w>j', opts)
map('n', '<A-k>', '<C-w>k', opts)
map('n', '<A-l>', '<C-w>l', opts)

-- Git
map('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Git status' })
map('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { desc = 'Git branches' })
map('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', { desc = 'Git commits' })
map('n', '<leader>gD', '<cmd>Gdiffsplit<CR>', { desc = 'Git diff split' })
map('n', '<leader>gl', '<cmd>G log --oneline --graph<CR>', { desc = 'Git log' })

-- Telescope
map('n', '<leader>f', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
map('n', '<leader>/', '<cmd>Telescope live_grep<CR>', { desc = 'Grep project' })
map('n', '<leader><leader>', '<cmd>Telescope buffers<CR>', { desc = 'Buffers' })
map('n', '<leader>:', '<cmd>Telescope commands<CR>', { desc = 'Commands' })

-- LSP
map('n', '<leader>ld', '<cmd>Telescope diagnostics<CR>', { desc = 'Diagnostics list' })
map('n', '<leader>gr', '<cmd>Telescope lsp_references<CR>', { desc = 'References' })
map('n', '<leader>gi', '<cmd>Telescope lsp_implementations<CR>', { desc = 'Implementations' })
map('n', '<leader>gd', '<cmd>Telescope lsp_definitions<CR>', { desc = 'Definitions' })
map('n', '<leader>gt', '<cmd>Telescope lsp_type_definitions<CR>', { desc = 'Type definitions' })

-- Diagnostics
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })
