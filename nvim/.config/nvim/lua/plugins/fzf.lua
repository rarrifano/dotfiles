-- fzf-lua

local util = require("util")

vim.pack.add({
	{ src = util.gh("ibhagwan/fzf-lua"), version = "267f5db2aa2202b9f6cc7a50783f0ccd2121766c" },
})

local fzf = require("fzf-lua")

fzf.setup({
	"telescope", -- telescope-style keymaps + layout
	-- explicitly disable all icons (no nvim-web-devicons / mini.icons needed)
	file_icons = false,
	git_icons = false,
	color_icons = false,
})

-- Override vim.ui.select
fzf.register_ui_select()

-- Files & search
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "[F]ind current [W]ord" })
vim.keymap.set("v", "<leader>fw", fzf.grep_visual, { desc = "[F]ind [W]ord (visual)" })
vim.keymap.set("n", "<leader>f.", fzf.oldfiles, { desc = "[F]ind Recent Files" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>fs", fzf.builtin, { desc = "[F]ind [S]elect fzf-lua" })

-- Vim
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>fc", fzf.commands, { desc = "[F]ind [C]ommands" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[ ] Find existing buffers" })

-- Current buffer
vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "[/] Search current buffer" })

-- Git
vim.keymap.set("n", "<leader>gf", fzf.git_files, { desc = "[G]it [F]iles" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "[G]it [B]ranches" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "[G]it [C]ommits" })
vim.keymap.set("n", "<leader>gC", fzf.git_bcommits, { desc = "[G]it Buffer [C]ommits" })
vim.keymap.set("n", "<leader>gt", fzf.git_status, { desc = "[G]it S[t]atus" })
vim.keymap.set("n", "<leader>gS", fzf.git_stash, { desc = "[G]it [S]tash" })

-- Neovim config
vim.keymap.set("n", "<leader>sn", function()
	fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[F]ind [N]eovim files" })
