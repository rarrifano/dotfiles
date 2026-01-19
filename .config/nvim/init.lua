vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = 'split'
vim.o.scrolloff = 10

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')
vim.keymap.set('n', '<leader>tt', '<cmd>ter<CR>')

vim.keymap.set('n', '<A-h>', '<cmd>wincmd h<CR>')
vim.keymap.set('n', '<A-j>', '<cmd>wincmd j<CR>')
vim.keymap.set('n', '<A-k>', '<cmd>wincmd k<CR>')
vim.keymap.set('n', '<A-l>', '<cmd>wincmd l<CR>')

vim.keymap.set('n', '<C-j>', '<cmd>bnext<CR>')
vim.keymap.set('n', '<C-k>', '<cmd>bprev<CR>')

vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>p', '"+p')
vim.keymap.set('v', '<leader>y', '"+y')

vim.keymap.set('n', '<leader>P', '"+P')
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set('v', '<leader>P', '"+P')
vim.keymap.set('v', '<leader>Y', '"+Y')

vim.keymap.set('n', '<leader>;', '<cmd>e $MYVIMRC<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>Ex<CR>')

vim.keymap.set('n', '<leader>fj', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope grep_string<CR>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')

vim.api.nvim_create_autocmd("FileType", {
	pattern = "yaml",
	callback = function()
		vim.bo.indentexpr = ''
	end,
})

vim.pack.add({
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/ellisonleao/gruvbox.nvim',
	'https://github.com/mason-org/mason.nvim',
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/nvim-mini/mini.completion',
	'https://github.com/lewis6991/gitsigns.nvim',
	'https://github.com/windwp/nvim-autopairs',
	'https://github.com/nvim-lua/plenary.nvim',
	'https://github.com/nvim-telescope/telescope.nvim',
})

require'nvim-treesitter.config'.setup { 
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true, disable = { "yaml" } },
	incremental_selection = { enable = true }
}

require("gruvbox").setup({
	transparent_mode = true
})

vim.cmd([[colorscheme gruvbox]])

vim.lsp.enable({
	'pyright',
	'yamlls'
})

vim.diagnostic.config({ virtual_text = true })

require'mason'.setup{}
require'mini.completion'.setup{}
require'gitsigns'.setup { current_line_blame = true }
require'nvim-autopairs'.setup{}
require'telescope'.setup{}
