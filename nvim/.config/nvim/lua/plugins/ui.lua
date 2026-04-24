return {
	-- ── Colorscheme ──────────────────────────────────────────────────────────
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				contrast = "hard",
				transparent_mode = true,
				italic = {
					strings = false,
					emphasis = false,
					comments = true,
					operators = false,
					folds = false,
				},
				overrides = {
					SignColumn = { bg = "NONE" },
					LineNr = { bg = "NONE" },
					CursorLineNr = { bg = "NONE" },
				},
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("gruvbox")
		end,
	},

	-- ── Statusline ───────────────────────────────────────────────────────────
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		opts = {
			options = {
				theme = "gruvbox",
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					{ "diff", symbols = { added = " +", modified = " ~", removed = " -" } },
					{ "diagnostics", symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" } },
				},
				lualine_c = { { "filename", path = 1 } }, -- relative path
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},
}
