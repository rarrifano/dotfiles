-- Treesitter syntax highlighting
return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        -- Ensure parsers are installed
        local ensure_installed = { 'terraform', 'python', 'bash', 'dockerfile', 'yaml', 'json', 'markdown', 'lua' }
        for _, lang in ipairs(ensure_installed) do
            pcall(vim.treesitter.language.add, lang)
        end

        -- Enable treesitter highlighting
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
