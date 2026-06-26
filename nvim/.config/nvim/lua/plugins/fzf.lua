-- fzf-lua
-- Pack load and setup are deferred so they don't affect startup time.
-- Keymaps use a lazy wrapper that requires fzf-lua on first invocation.

local util = require("util")

vim.schedule(function()
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
end)

-- Lazy wrapper: calls fzf-lua method only when the keymap is triggered.
local function fzf_call(method, opts)
	return function()
		require("fzf-lua")[method](opts)
	end
end

-- Files & search
vim.keymap.set("n", "<leader>ff", fzf_call("files"), { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fg", fzf_call("live_grep"), { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fw", fzf_call("grep_cword"), { desc = "[F]ind current [W]ord" })
vim.keymap.set("v", "<leader>fw", fzf_call("grep_visual"), { desc = "[F]ind [W]ord (visual)" })
vim.keymap.set("n", "<leader>f.", fzf_call("oldfiles"), { desc = "[F]ind Recent Files" })
vim.keymap.set("n", "<leader>fr", fzf_call("resume"), { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>fs", fzf_call("builtin"), { desc = "[F]ind [S]elect fzf-lua" })

-- Vim
vim.keymap.set("n", "<leader>fh", fzf_call("helptags"), { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", fzf_call("keymaps"), { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>fc", fzf_call("commands"), { desc = "[F]ind [C]ommands" })
vim.keymap.set("n", "<leader>fd", fzf_call("diagnostics_workspace"), { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader><leader>", fzf_call("buffers"), { desc = "[ ] Find existing buffers" })

-- Current buffer
vim.keymap.set("n", "<leader>/", fzf_call("lgrep_curbuf"), { desc = "[/] Search current buffer" })

-- Git
vim.keymap.set("n", "<leader>gf", fzf_call("git_files"), { desc = "[G]it [F]iles" })
vim.keymap.set("n", "<leader>gb", fzf_call("git_branches"), { desc = "[G]it [B]ranches" })
vim.keymap.set("n", "<leader>gc", fzf_call("git_commits"), { desc = "[G]it [C]ommits" })
vim.keymap.set("n", "<leader>gC", fzf_call("git_bcommits"), { desc = "[G]it Buffer [C]ommits" })
vim.keymap.set("n", "<leader>gt", fzf_call("git_status"), { desc = "[G]it S[t]atus" })
vim.keymap.set("n", "<leader>gS", fzf_call("git_stash"), { desc = "[G]it [S]tash" })

-- Neovim config
vim.keymap.set("n", "<leader>sn", function()
	require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[F]ind [N]eovim files" })
