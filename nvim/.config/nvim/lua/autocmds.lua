-- autocmds

-- Register custom YAML sub-filetypes so yamlls can attach to them.
-- Deferred to first BufReadPre so vim.filetype isn't loaded at startup (~3ms).
vim.api.nvim_create_autocmd("BufReadPre", {
	once = true,
	callback = function()
		vim.filetype.add({
			pattern = {
				["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
				['.+%.ya?ml'] = function(path, _)
					local f = io.open(path, 'r')
					if f then
						local head = f:read(2048) or ''
						f:close()
						if head:match('stages:%s*%[') or head:match('%-%-%-%s*stages:') then
							return 'yaml.gitlab'
						end
						if head:match('apiVersion:') and (head:match('type:%s*library') or head:match('type:%s*application')) then
							return 'yaml.helm-values'
						end
					end
					return nil
				end,
			},
		})
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Per-filetype indent overrides
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "python" },
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- Auto-reload files changed on disk
-- autoread alone only kicks in on a handful of events; checktime forces the check
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	desc = "Reload file if changed on disk",
	group = vim.api.nvim_create_augroup("auto-reload", { clear = true }),
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})
