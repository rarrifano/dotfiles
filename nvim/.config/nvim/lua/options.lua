-- options

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.showmode = false
-- termguicolors: auto-enabled since nvim 0.10 when terminal supports truecolor

vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wrap = false
vim.o.cursorline = false
vim.o.autoread = true
vim.o.completeopt = "menuone,noinsert,noselect,popup,fuzzy"

vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"

-- Indentation defaults (replaces guess-indent.nvim)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
