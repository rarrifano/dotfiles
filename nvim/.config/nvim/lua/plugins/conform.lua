-- Conform formatter
return {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
        formatters_by_ft = {
            yaml = { 'prettier' },
            json = { 'prettier' },
            sh = { 'shfmt' },
            terraform = { 'terraform_fmt' },
            python = { 'black' },
            markdown = { 'prettier' },
            lua = { 'stylua' },
        },
        format_on_save = function(bufnr)
            if vim.tbl_contains({ 'gitcommit', 'markdown' }, vim.bo[bufnr].filetype) then
                return nil
            end
            return { timeout_ms = 500, lsp_fallback = true }
        end,
    },
}
