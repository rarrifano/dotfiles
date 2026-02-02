-- LSP configuration (Mason + nvim-lspconfig)
return {
    {
        'williamboman/mason.nvim',
        opts = {},
    },
    {
        'williamboman/mason-lspconfig.nvim',
        opts = {
            ensure_installed = { 'terraformls', 'pyright', 'bashls', 'dockerls', 'yamlls', 'jsonls' },
        },
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemas = {
                            ['https://json.schemastore.org/kubernetes.json'] = '/*.k8s.yaml',
                            ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '/docker-compose*.yml',
                        },
                    },
                },
            })
            vim.lsp.enable({ 'yamlls', 'pyright', 'bashls', 'dockerls', 'jsonls', 'terraformls' })
        end,
    },
}
