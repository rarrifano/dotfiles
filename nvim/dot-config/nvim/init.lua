-- init.lua

vim.cmd.colorscheme("retrobox")
vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")

vim.opt.number = true

vim.opt.grepformat = "%f:%l:%m"
vim.opt.grepprg = "git grep -n --no-color"

vim.keymap.set("n", "[q", "<cmd>cprevious<CR>")
vim.keymap.set("n", "]q", "<cmd>cnext<CR>")
