vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("autocmds")
require("diagnostics")

require("plugins.build")
require("plugins.ui")
require("plugins.telescope")
require("plugins.lsp")
require("plugins.conform")
require("plugins.completion")
