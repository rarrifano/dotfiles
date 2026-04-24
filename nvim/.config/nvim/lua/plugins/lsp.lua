return {
  -- ── Mason: LSP server installer ───────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = { ui = { border = "rounded" } },
  },

  -- ── mason-lspconfig: auto-install servers ─────────────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "gopls",
        "pyright",
        "bashls",
        "terraformls",
        "tflint",
        "dockerls",
        "yamlls",
        "jsonls",
        "lua_ls",
      },
      automatic_installation = true,
    },
  },

  -- ── lazydev: Lua annotations for Neovim config editing ───────────────────
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },

  -- ── fidget: LSP progress notifications ───────────────────────────────────
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = { window = { winblend = 0 } },
    },
  },

  -- ── nvim-lspconfig: server configs (0.11 native API) ─────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Capabilities extended by blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text     = { prefix = ">" },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded" },
      })

      -- Helm template filetype detection — prevent yamlls false errors
      vim.filetype.add({
        pattern = {
          [".*templates/.*%.yaml"] = "helm",
          [".*templates/.*%.tpl"]  = "helm",
        },
      })

      -- ── Server configs via 0.11 vim.lsp.config API ──────────────────────

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses      = { unusedparams = true },
            staticcheck   = true,
            gofumpt       = true,
          },
        },
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode   = "basic",
              autoSearchPaths    = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("bashls",     { capabilities = capabilities })
      vim.lsp.config("terraformls",{ capabilities = capabilities })
      vim.lsp.config("tflint",     { capabilities = capabilities })
      vim.lsp.config("dockerls",   { capabilities = capabilities })

      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            keyOrdering = false,
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"]                                                                          = ".github/workflows/*.yml",
              ["https://json.schemastore.org/kubernetes.json"]                                                                               = "*.k8s.yaml",
              ["https://json.schemastore.org/chart.json"]                                                                                    = "Chart.yaml",
              ["https://json.schemastore.org/kustomization.json"]                                                                            = "kustomization.yaml",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        capabilities = capabilities,
        settings = {
          json = { validate = { enable = true } },
        },
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime   = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library         = { vim.env.VIMRUNTIME },
            },
            diagnostics = { globals = { "vim" } },
            telemetry   = { enable = false },
          },
        },
      })

      -- Enable all configured servers
      vim.lsp.enable({
        "gopls", "pyright", "bashls", "terraformls", "tflint",
        "dockerls", "yamlls", "jsonls", "lua_ls",
      })

      -- ── Buffer-local keymaps on LSP attach ──────────────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = buf, desc = "LSP: " .. desc })
          end

          map("gd",         vim.lsp.buf.definition,     "Go to definition")
          map("gD",         vim.lsp.buf.declaration,    "Go to declaration")
          map("gr",         vim.lsp.buf.references,     "References")
          map("gI",         vim.lsp.buf.implementation, "Go to implementation")
          map("K",          vim.lsp.buf.hover,          "Hover docs")
          map("<C-k>",      vim.lsp.buf.signature_help, "Signature help")
          map("<leader>ca", vim.lsp.buf.code_action,    "Code action")
          map("<leader>rn", vim.lsp.buf.rename,         "Rename symbol")
          map("[d",         vim.diagnostic.goto_prev,   "Prev diagnostic")
          map("]d",         vim.diagnostic.goto_next,   "Next diagnostic")
        end,
      })
    end,
  },

  -- ── blink.cmp: completion ─────────────────────────────────────────────────
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset      = "default",
        ["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"]    = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        -- Snippet tabstop jumping
        ["<C-l>"]   = { "snippet_forward",  "fallback" },
        ["<C-h>"]   = { "snippet_backward", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
      },
      sources = {
        default = { "lsp", "buffer", "snippets", "path" },
      },
      snippets = { preset = "default" },
      completion = {
        documentation = {
          auto_show       = true,
          auto_show_delay_ms = 200,
          window          = { border = "rounded" },
        },
        menu = {
          border = 'rounded',
          -- Remove the kind-icon column entirely — no Nerd Font needed
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind' },
            },
          },
        },
      },
    },
  },
}
