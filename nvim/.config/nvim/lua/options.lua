local opt = vim.opt

-- Leader (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers (cleaner :checkhealth)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs / indentation (4 spaces — matches muscle memory)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Wrapping
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Split behaviour
opt.splitright = true
opt.splitbelow = true

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.autoread = true -- auto-reload files changed on disk (required by opencode.nvim)

-- Performance
opt.updatetime = 50 -- faster CursorHold → snappier gitsigns blame + LSP
opt.timeoutlen = 400

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Mouse: disabled — keyboard centric
opt.mouse = ""

-- Clipboard: NOT set to unnamedplus intentionally.
-- Use <leader>y to explicitly yank to system clipboard.
-- OSC 52 passthrough (tmux: set-clipboard on) handles cross-pane yank.

-- Misc
opt.showmode = false -- lualine shows mode
opt.showcmd = false
opt.laststatus = 3 -- global statusline
opt.isfname:append("@-@")
opt.shortmess:append("sI") -- suppress intro + search messages
opt.fillchars = { eob = " " } -- hide ~ on empty lines
