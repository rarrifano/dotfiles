local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug ('morhetz/gruvbox')
Plug ('christoomey/vim-tmux-navigator')
Plug ('nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.7.2' })

vim.call('plug#end')

vim.cmd('colorscheme gruvbox')
vim.opt.termguicolors=true
vim.g.gruvbox_transparent_background=1
vim.g.gruvbox_gruvbox_italic=1

require'nvim-treesitter.configs'.setup {
    highlight = { enable = true }, 
    indent = { enable = true }
}

vim.opt.backup=false
vim.opt.expandtab=true
vim.opt.hidden=true
vim.opt.hlsearch=false
vim.opt.laststatus=1
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.shiftwidth=4
vim.opt.softtabstop=4
vim.opt.tabstop=4
vim.opt.splitbelow=true
vim.opt.splitright=true
vim.opt.swapfile=false
vim.opt.undofile=true
vim.opt.wrap=false

vim.g.mapleader=' '
vim.g.netrw_banner=0
vim.g.netrw_gh=0
vim.g.netrw_hide=1

vim.keymap.set('n', '<leader>ee', ':Ex<CR>', { silent = true })
vim.keymap.set('n', '<leader>op', ':e $MYVIMRC<CR>', { silent = true })

vim.keymap.set('n', '<leader>p', '"+p', { silent = true })
vim.keymap.set('n', '<leader>y', '"+y', { silent = true })
vim.keymap.set('v', '<leader>p', '"+p', { silent = true })
vim.keymap.set('v', '<leader>y', '"+y', { silent = true })

vim.keymap.set('n', '<M-h>', ':wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<M-j>', ':wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<M-k>', ':wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<M-l>', ':wincmd l<CR>', { silent = true })

vim.keymap.set('t', '<ESC>', [[<C-\><C-n>]], { silent = true })
