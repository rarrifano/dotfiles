-- ~/.config/nvim/lua/config/options.lua

vim.g.mapleader = " "

vim.opt.updatetime = 100

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.mouse = "a"
vim.opt.undofile = true

vim.opt.signcolumn = "yes"

vim.opt.list = true
vim.opt.listchars = { tab = "> ", trail = "-", nbsp = "+" }
