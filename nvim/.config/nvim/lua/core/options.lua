-- Core Neovim options

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = ''
opt.clipboard = ''
opt.undofile = true
opt.swapfile = false
opt.termguicolors = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.signcolumn = 'yes'
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.cursorline = false
opt.scrolloff = 8
opt.autoread = true

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Point Node.js provider to mise-managed neovim-node-host
vim.g.node_host_prog = vim.fn.exepath('neovim-node-host')

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ timeout = 150 })
    end,
})
