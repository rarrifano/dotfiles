local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Trim trailing whitespace on save ─────────────────────────────────────────
autocmd("BufWritePre", {
	group = augroup("TrimWhitespace", { clear = true }),
	callback = function()
		local pos = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[%s/\s\+$//e]])
		vim.api.nvim_win_set_cursor(0, pos)
	end,
})

-- ── Highlight on yank ─────────────────────────────────────────────────────────
autocmd("TextYankPost", {
	group = augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

-- ── Restore cursor position ───────────────────────────────────────────────────
autocmd("BufReadPost", {
	group = augroup("RestoreCursor", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- ── Close auxiliary windows with q ───────────────────────────────────────────
autocmd("FileType", {
	group = augroup("QuickClose", { clear = true }),
	pattern = { "help", "qf", "man", "checkhealth", "startuptime", "lspinfo" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf })
	end,
})

-- ── Terraform: set correct filetype ──────────────────────────────────────────
autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("TerraformFT", { clear = true }),
	pattern = { "*.tf", "*.tfvars" },
	callback = function()
		vim.bo.filetype = "terraform"
	end,
})

-- ── Dockerfile: set correct filetype ─────────────────────────────────────────
autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("DockerfileFT", { clear = true }),
	pattern = { "Dockerfile*", "*.dockerfile" },
	callback = function()
		vim.bo.filetype = "dockerfile"
	end,
})

-- ── Auto-resize splits when terminal is resized ───────────────────────────────
autocmd("VimResized", {
	group = augroup("AutoResize", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})
