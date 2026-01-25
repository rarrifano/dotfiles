-- Only return the plugin spec, do not setup lazy here!
return {
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                overrides = {
                    SignColumn = { bg = "NONE" },
                    LineNr = { bg = "NONE" },
                    CursorLineNr = { bg = "NONE" },
                },
            })
            vim.o.background = "dark"
            vim.cmd("colorscheme gruvbox")
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('telescope').setup {
                defaults = {
                    file_ignore_patterns = {
                        "node_modules", '.git/', '.terraform', '.venv', 'target/', '.cache/', 'vendor/', 'dist/', '.DS_Store$', '.pyc$'
                    },
                }
            }
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.config').setup {
                ensure_installed = {'terraform', 'python', 'bash', 'dockerfile', 'yaml', 'json', 'markdown'},
                highlight = { enable = true },
                indent = { enable = true },
            }
        end,
    },
    {
        'williamboman/mason.nvim',
        config = function() require('mason').setup() end,
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require('mason-lspconfig').setup {
                ensure_installed = {'terraformls', 'pyright', 'bashls', 'dockerls', 'yamlls', 'jsonls'}
            }
        end,
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/kubernetes.json"] = "/*.k8s.yaml",
                            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
                        }
                    }
                }
            })
            vim.lsp.enable('yamlls')
            vim.lsp.enable('pyright')
            vim.lsp.enable('bashls')
            vim.lsp.enable('dockerls')
            vim.lsp.enable('jsonls')
            vim.lsp.enable('terraformls')
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        config = function()
            local cmp = require'cmp'
            local luasnip = require'luasnip'
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                })
            }
        end,
    },
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {
        'L3MON4D3/LuaSnip',
        config = function()
            local ls = require'luasnip'
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            ls.add_snippets(nil, {
                terraform = {
                    s("resource", { t('resource "'), i(1, "type"), t('" "'), i(2, "name"), t('" {\n  '), t('\n}') }),
                    s("provider", { t('provider "'), i(1, "name"), t('" {\n  '), t('\n}') })
                },
                sh = {
                    s("shebang", { t("#!/bin/bash\nset -e\n") }),
                    s("func", { t("function "), i(1, "name"), t("() {\n  "), i(2), t("\n}\n") })
                },
                dockerfile = {
                    s("base", { t("FROM "), i(1, "alpine:latest") }),
                    s("run", { t("RUN "), i(1, "echo Hello") })
                },
                yaml = {
                    s("k8sdeploy", {
                        t({'apiVersion: apps/v1', 'kind: Deployment', 'metadata:', '  name: '}), i(1, "name"), t({'', 'spec:', '  replicas: '}), i(2, "1"), t({'', '  template:', '    metadata:', '      labels:', '        app: '}), i(3, "label"), t({'', '    spec:', '      containers:', '      - name: '}), i(4, "container"), t({'', '        image: '}), i(5, "image:tag"), t({''}),
                    })
                },
                python = {
                    s("func", { t("def "), i(1, "function_name"), t("():\n    "), i(2, "pass") }),
                    s("class", { t("class "), i(1, "ClassName"), t(":\n    def __init__(self):\n        "), i(2, "pass") })
                },
            })
        end,
    },
    { 'stevearc/conform.nvim', config = function()
        require('conform').setup {
            formatters_by_ft = {
                yaml = { 'yamlfmt', 'prettier' },
                json = { 'jq', 'prettier' },
                dockerfile = { 'dockerfile_fmt' },
                sh = { 'shfmt' },
                terraform = { 'terraform_fmt' },
                python = { 'black' },
                markdown = { 'prettier', 'mdformat' },
            },
            format_on_save = function(bufnr)
                local ignore = vim.tbl_contains({ "gitcommit", "markdown" }, vim.bo[bufnr].filetype)
                return not ignore
            end,
            notify_on_error = false,
        }
    end, },
    {
        'lewis6991/gitsigns.nvim',
        config = function() require('gitsigns').setup() end,
    },
    {'tpope/vim-fugitive'},
    { 'folke/trouble.nvim',
      config = function()
        require('trouble').setup {}
        vim.keymap.set('n', '<leader>xx', function() require('trouble').toggle() end, {desc = 'Trouble Diagnostics'})
        vim.keymap.set('n', '<leader>xw', function() require('trouble').toggle('workspace_diagnostics') end, {desc = 'Workspace diagnostics'})
        vim.keymap.set('n', '<leader>xd', function() require('trouble').toggle('document_diagnostics') end, {desc = 'Document diagnostics'})
        vim.keymap.set('n', '<leader>xq', function() require('trouble').toggle('quickfix') end, {desc = 'Quickfix list'})
        vim.keymap.set('n', '<leader>xl', function() require('trouble').toggle('loclist') end, {desc = 'Location list'})
        vim.keymap.set('n', '<leader>xr', function() require('trouble').toggle('lsp_references') end, {desc = 'LSP references'})
      end,
    },
    {
        'stevearc/oil.nvim',
        config = function()
            require("oil").setup{}
            vim.keymap.set('n', '-', require('oil').open, { desc = 'Open Oil (file browser)' })
        end,
    },
    {
        'windwp/nvim-autopairs',
        config = function() require('nvim-autopairs').setup {} end,
    },
}
