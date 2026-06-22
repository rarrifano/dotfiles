vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused remote providers (silences :checkhealth warnings)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

require("options")
require("keymaps")
require("autocmds")
require("diagnostics")

require("plugins.ui")
require("plugins.fzf")
require("plugins.conform")
require("plugins.lsp")
