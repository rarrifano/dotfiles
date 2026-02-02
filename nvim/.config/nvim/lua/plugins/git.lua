-- Git integration (gitsigns + fugitive)
return {
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
                virt_text_pos = 'eol',
            },
            on_attach = function()
                vim.cmd.highlight('GitSignsCurrentLineBlame guifg=#585850 gui=italic')
            end,
        },
    },
    { 'tpope/vim-fugitive' },
}
