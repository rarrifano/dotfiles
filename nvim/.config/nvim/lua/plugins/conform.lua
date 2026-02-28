-- Conform formatter
return {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
        formatters_by_ft = {
            hcl = { 'terraform_fmt' },
            json = { 'prettier' },
            lua = { 'stylua' },
            markdown = { 'prettier' }, -- manual only: format-on-save disabled for markdown
            python = { 'black' },
            sh = { 'shfmt' },
            terraform = { 'terraform_fmt' },
            toml = { 'taplo' },
            yaml = { 'prettier' },
        },
        format_on_save = function(bufnr)
            if vim.tbl_contains({ 'gitcommit', 'markdown' }, vim.bo[bufnr].filetype) then
                return nil
            end
            return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
    },
}
