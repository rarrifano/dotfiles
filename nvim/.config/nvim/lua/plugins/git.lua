-- Git integration (gitsigns + fugitive)
return {
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 300,
                virt_text_pos = 'eol',
            },
            on_attach = function(bufnr)
                local gs = require('gitsigns')
                vim.cmd.highlight('GitSignsCurrentLineBlame guifg=#585850 gui=italic')

                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                map('n', ']h', gs.next_hunk, 'Next hunk')
                map('n', '[h', gs.prev_hunk, 'Prev hunk')
                map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
                map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
                map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
            end,
        },
    },
    { 'tpope/vim-fugitive', cmd = { 'G', 'Git', 'Gdiffsplit', 'Gvdiffsplit' } },
}
