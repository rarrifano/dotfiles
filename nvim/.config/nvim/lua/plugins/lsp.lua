-- lsp

local util = require("util")
local spec = util.spec

-- Provides server defaults (cmd, filetypes, root_markers) without the
-- deprecated require('lspconfig') framework
vim.pack.add({
	spec("neovim/nvim-lspconfig", "v2.4.0"),
})

-- Keymaps applied when an LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local buf = event.buf
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gr", vim.lsp.buf.references, "Go to references")
		map("gi", vim.lsp.buf.implementation, "Go to implementation")
		map("K", vim.lsp.buf.hover, "Hover docs")
		map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("<leader>cd", vim.diagnostic.open_float, "Show diagnostics")
		map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
		map("]d", vim.diagnostic.goto_next, "Next diagnostic")
	end,
})

-- Server configs (overrides on top of nvim-lspconfig defaults)
vim.lsp.config("terraformls", {})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
			schemas = {
				kubernetes = { "*.k8s.yaml", "*.k8s.yml", "k8s/**/*.yaml", "k8s/**/*.yml" },
			},
		},
	},
})

vim.lsp.config("bashls", {})

vim.lsp.config("jsonls", {
	settings = {
		json = {
			validate = { enable = true },
		},
	},
})

vim.lsp.config("pyright", {
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				-- make lua_ls aware of nvim runtime + all installed plugins
				library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), { vim.fn.stdpath("config") }),
			},
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.enable({
	"terraformls",
	"yamlls",
	"bashls",
	"jsonls",
	"pyright",
	"lua_ls",
})
