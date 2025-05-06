-- UI options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 1
vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.showcmd = true

-- Search options
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- File handling
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.hidden = true
vim.opt.autoread = true

-- Indentation
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Misc options
vim.opt.mouse = ""
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
vim.opt.updatetime = 300
vim.opt.history = 1000
vim.opt.undolevels = 1000
vim.opt.title = true
vim.opt.ttyfast = true
vim.opt.shortmess:append "c"
vim.opt.lazyredraw = true

-- Backspace behavior
vim.opt.backspace = { "indent", "eol", "start" }

-- Miscellaneous
vim.opt.complete:remove("i")
vim.opt.nrformats:remove("octal")
vim.opt.display:append("lastline")
vim.opt.formatoptions:append("j")

-- Leader key
vim.g.mapleader = " "

-- Colorscheme
vim.opt.background = "dark"
