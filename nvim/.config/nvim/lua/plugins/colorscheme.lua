-- Gruvbox colorscheme
return {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
        require('gruvbox').setup({
            overrides = {
                SignColumn = { bg = 'NONE' },
                LineNr = { bg = 'NONE' },
                CursorLineNr = { bg = 'NONE' },
            },
        })
        vim.o.background = 'dark'
        vim.cmd.colorscheme('gruvbox')
    end,
}
