return {
	{
		"nickjvandyke/opencode.nvim",
		version = "*",
		-- Load on demand — don't eat startup time
		keys = {
			{
				"<leader>oo",
				function()
					require("opencode").ask("", { submit = true })
				end,
				mode = { "n", "x" },
				desc = "Opencode: Send selection/context",
			},
		},
		cmd = { "Opencode", "OpencodeAsk" },
		-- opencode.nvim has no setup() function; disable lazy's auto-setup call
		config = false,
		init = function()
			-- Required by opencode.nvim: auto-reload buffers changed on disk
			vim.o.autoread = true
			-- Trigger autoread when focus is gained or a buffer is entered
			vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
				group = vim.api.nvim_create_augroup("OpencodeAutoread", { clear = true }),
				callback = function()
					if vim.fn.mode() ~= "c" then
						vim.cmd("silent! checktime")
					end
				end,
			})
		end,
	},
}
