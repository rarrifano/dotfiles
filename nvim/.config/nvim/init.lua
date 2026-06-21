vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("autocmds")
require("diagnostics")

require("plugins.ui")
require("plugins.fzf")
require("plugins.conform")
require("plugins.lsp")
