local cmp = require('cmp')

cmp.setup({
    sources = {
        {name = 'nvim_lsp'},
        {name = 'buffer'},
    },
    mapping = cmp.mapping.preset.insert({
        -- Simple tab complete
        ['<Tab>'] = cmp.mapping(function(fallback)
            local col = vim.fn.col('.') - 1

            if cmp.visible() then
                cmp.select_next_item({behavior = 'select'})
            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
            else
                cmp.complete()
            end
        end, {'i', 's'}),

        -- Go to previous item
        ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    }),
    cmp.setup({
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({select = false}),
        })
    })
})
