-- LSP configuration (Mason + nvim-lspconfig)
return {
    {
        'williamboman/mason.nvim',
        opts = {},
    },
    {
        'williamboman/mason-lspconfig.nvim',
        opts = {
            ensure_installed = { 'terraformls', 'pyright', 'bashls', 'dockerls', 'yamlls', 'jsonls', 'lua_ls' },
        },
    },
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {},
    },
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
        config = function()
            -- Helm template filetype detection — prevent yamlls false errors
            vim.filetype.add({
                pattern = {
                    ['.*templates/.*%.yaml'] = 'helm',
                    ['.*templates/.*%.tpl'] = 'helm',
                },
            })

            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemas = {
                            ['https://json.schemastore.org/kubernetes.json'] = '/*.k8s.yaml',
                            ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '/docker-compose*.yml',
                            ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                            ['https://json.schemastore.org/chart.json'] = '/Chart.yaml',
                            ['https://json.schemastore.org/kustomization.json'] = '/kustomization.yaml',
                            ['https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json'] = '/.gitlab-ci.yml',
                        },
                    },
                },
            })
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        workspace = {
                            library = { vim.env.VIMRUNTIME },
                            checkThirdParty = false,
                        },
                    },
                },
            })
            vim.lsp.enable({ 'yamlls', 'pyright', 'bashls', 'dockerls', 'jsonls', 'terraformls', 'lua_ls' })

            -- LspAttach keymaps — buffer-local, only active when an LSP is attached
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local buf = args.buf
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
                    end

                    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
                    map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
                    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
                    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
                    map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
                end,
            })
        end,
    },
}
