-- lsp

local util = require("util")
local spec = util.spec

-- Provides server defaults (cmd, filetypes, root_markers) without the
-- deprecated require('lspconfig') framework
vim.pack.add({
	spec("neovim/nvim-lspconfig", "v2.4.0"),
})

-- Keymaps + native LSP completion applied when an LSP attaches to a buffer
-- gd, gD, grr, gri, grn, gra, K are default in nvim 0.12; only add extras here
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local buf = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
		end

		map("<leader>cd", vim.diagnostic.open_float, "Show diagnostics")
		map("[d", function() vim.diagnostic.jump({ count = -1, on_jump = function(_diag, _buf) vim.diagnostic.open_float() end }) end, "Previous diagnostic")
		map("]d", function() vim.diagnostic.jump({ count = 1, on_jump = function(_diag, _buf) vim.diagnostic.open_float() end }) end, "Next diagnostic")

		-- Native LSP completion (0.11+): wires LSP into C-n/C-p without nvim-cmp.
		-- autotrigger fires on server-defined triggerCharacters (e.g. '.', ':', '/').
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })

			-- <C-n>/<C-p> navigate LSP popup; fall back to built-in complete when no popup
			local function pumvisible() return tonumber(vim.fn.pumvisible()) == 1 end
			vim.keymap.set("i", "<C-n>", function()
				return pumvisible() and "<C-n>" or "<C-x><C-o>"
			end, { buffer = buf, expr = true, desc = "LSP next completion" })
			vim.keymap.set("i", "<C-p>", function()
				return pumvisible() and "<C-p>" or "<C-x><C-o>"
			end, { buffer = buf, expr = true, desc = "LSP prev completion" })
			-- <CR> confirms selection only when popup is visible
			vim.keymap.set("i", "<CR>", function()
				return pumvisible() and "<C-y>" or "<CR>"
			end, { buffer = buf, expr = true, desc = "Confirm completion" })
		end
	end,
})

-- Server configs (overrides on top of nvim-lspconfig defaults)
-- terraformls and bashls use lspconfig defaults as-is
vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
			schemas = {
				kubernetes = { "*.k8s.yaml", "*.k8s.yml", "k8s/**/*.yaml", "k8s/**/*.yml" },
				["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = { "docker-compose*.yml", "docker-compose*.yaml" },
				["https://raw.githubusercontent.com/ansible/schemas/main/f/ansible-playbook.json"] = { "playbooks/*.yml", "playbooks/*.yaml" },
			},
		},
	},
})

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
	"docker_compose_language_service",
	"helm_ls",
	"ansiblels",
	"taplo",
})
