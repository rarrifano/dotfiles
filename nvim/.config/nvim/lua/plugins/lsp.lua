-- lsp

local function gh(repo)
  return "https://github.com/" .. repo
end

local function spec(repo, version)
  return { src = gh(repo), version = version }
end

vim.pack.add({ spec("j-hui/fidget.nvim", "v1.6.1") })
require("fidget").setup({})

vim.pack.add({
  spec("neovim/nvim-lspconfig", "v2.9.0"),
  spec("mason-org/mason.nvim", "v2.3.0"),
  spec("mason-org/mason-lspconfig.nvim", "v2.2.0"),
  spec("WhoIsSethDaniel/mason-tool-installer.nvim", "main"),
})

-- LSP servers: configured and enabled via vim.lsp
local lsp_servers = {
  lua_ls = {
    on_init = function(client)
      -- formatting delegated to stylua
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          version = "LuaJIT",
          path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
            "${3rd}/luv/library",
            "${3rd}/busted/library",
          }),
        },
      })
    end,
    settings = {
      Lua = {
        format = { enable = false },
      },
    },
  },
  pyright = {
    settings = {
      pyright = {
        -- Using ruff for import sorting and organizing
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          -- Ignore hints that conflict with or duplicate ruff diagnostics
          ignore = { "*" },
        },
      },
    },
  },
  ruff = {
    on_attach = function(client, bufnr)
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end,
  },

  gopls = {
    settings = {
      gopls = {
        hints = {
          assignVariableTypes    = true,
          compositeLiteralFields = true,
          functionTypeParameters = true,
          parameterNames         = true,
          rangeVariableTypes     = true,
        },
      },
    },
  },

  terraformls = {},

  yamlls = {
    settings = {
      yaml = {
        validate   = true,
        completion = true,
        hover      = true,
        schemas = {
          -- GitHub Actions
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
          -- Docker Compose
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
            "docker-compose*.{yml,yaml}",
            "compose*.{yml,yaml}",
          },
          -- Kubernetes (explicit paths to avoid false positives on all yaml)
          kubernetes = {
            "k8s/**/*.{yml,yaml}",
            "manifests/**/*.{yml,yaml}",
            "*.k8s.yaml",
          },
        },
      },
    },
  },
}

-- Mason-only tools: formatters/linters, not LSP servers
local mason_tools = {
  "stylua",
  "goimports",
}

require("mason").setup({})
require("mason-tool-installer").setup({
  ensure_installed = vim.list_extend(vim.tbl_keys(lsp_servers), mason_tools),
})

for name, server in pairs(lsp_servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/documentHighlight", event.buf) then
      local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client:supports_method("textDocument/inlayHint", event.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})
