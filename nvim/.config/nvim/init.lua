-- Minimalist Neovim IDE for DevOps (Gruvbox, Lazy.nvim)

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath('data')..'/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('core.options')
require('core.keymaps')
require("lazy").setup(require("plugins.lazy_setup"))
require('plugins')

-- Set Gruvbox colorscheme after plugins load
vim.cmd('colorscheme gruvbox')

vim.o.mouse = ""


