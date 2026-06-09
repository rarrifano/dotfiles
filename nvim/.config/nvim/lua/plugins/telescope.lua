-- telescope

local function gh(repo)
	return "https://github.com/" .. repo
end

local function spec(repo, version)
	return { src = gh(repo), version = version }
end

local plugins = {
	spec("nvim-lua/plenary.nvim", "v0.1.4"),
	spec("nvim-telescope/telescope.nvim", "v0.2.2"),
}
if vim.fn.executable("make") == 1 then
	table.insert(plugins, spec("nvim-telescope/telescope-fzf-native.nvim", "main"))
end

vim.pack.add(plugins)

require("telescope").setup({})

pcall(require("telescope").load_extension, "fzf")

-- Native vim.ui.select with fuzzy filtering via matchfuzzypos
vim.ui.select = function(items, opts, on_choice)
	opts = opts or {}
	local prompt = (opts.prompt or "Select") .. "> "
	local format = opts.format_item or tostring

	local lines = vim.tbl_map(format, items)
	local filtered = { indices = vim.fn.range(1, #items) }

	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.min(60, vim.o.columns - 4)
	local height = math.min(#items + 2, 15)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " " .. (opts.prompt or "Select") .. " ",
		title_pos = "center",
	})

	local query = ""
	local cursor_idx = 1

	local function render()
		if #query > 0 then
			local results = vim.fn.matchfuzzypos(lines, query)
			filtered.indices = vim.tbl_map(function(i) return i + 1 end, results[2])
		else
			filtered.indices = vim.fn.range(1, #items)
		end
		cursor_idx = math.min(cursor_idx, math.max(1, #filtered.indices))

		local display = { prompt .. query }
		for i, idx in ipairs(filtered.indices) do
			local prefix = i == cursor_idx and "> " or "  "
			display[#display + 1] = prefix .. lines[idx]
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, display)
		vim.api.nvim_win_set_cursor(win, { cursor_idx + 1, 0 })
	end

	local function confirm()
		local idx = filtered.indices[cursor_idx]
		vim.api.nvim_win_close(win, true)
		on_choice(idx and items[idx] or nil, idx)
	end

	local function cancel()
		vim.api.nvim_win_close(win, true)
		on_choice(nil, nil)
	end

	render()
	vim.keymap.set("i", "<CR>",  confirm, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<C-y>", confirm, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<Esc>", cancel,  { buffer = buf, nowait = true })
	vim.keymap.set("i", "<C-c>", cancel, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<C-n>", function()
		cursor_idx = math.min(cursor_idx + 1, math.max(1, #filtered.indices))
		render()
	end, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<C-p>", function()
		cursor_idx = math.max(cursor_idx - 1, 1)
		render()
	end, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<BS>", function()
		query = query:sub(1, -2)
		cursor_idx = 1
		render()
	end, { buffer = buf, nowait = true })

	vim.api.nvim_create_autocmd("InsertCharPre", {
		buffer = buf,
		once = false,
		callback = function()
			query = query .. vim.v.char
			vim.v.char = ""
			cursor_idx = 1
			render()
		end,
	})

	vim.cmd("startinsert")
end

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
vim.keymap.set({ "n", "v" }, "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[F]ind [C]ommands" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "[G]it [F]iles" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "[G]it [B]ranches" })
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
vim.keymap.set("n", "<leader>gC", builtin.git_bcommits, { desc = "[G]it Buffer [C]ommits" })
vim.keymap.set("n", "<leader>gt", builtin.git_status, { desc = "[G]it S[t]atus" })
vim.keymap.set("n", "<leader>gS", builtin.git_stash, { desc = "[G]it [S]tash" })

vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[F]ind [/] in Open Files" })

vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[F]ind [N]eovim files" })

-- LSP pickers wired up on attach so builtin is in scope
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
	callback = function(event)
		local buf = event.buf
		vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
		vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
		vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
		vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })
		vim.keymap.set(
			"n",
			"gW",
			builtin.lsp_dynamic_workspace_symbols,
			{ buffer = buf, desc = "Open Workspace Symbols" }
		)
		vim.keymap.set("n", "grt", builtin.lsp_type_definitions, { buffer = buf, desc = "[G]oto [T]ype Definition" })
	end,
})
