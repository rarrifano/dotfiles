-- OpenCode AI assistant integration
return {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {}

        local map = vim.keymap.set
        map({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode' })
        map({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Opencode select' })
        map({ 'n', 't' }, '<leader>oo', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
        map({ 'n', 'x' }, 'go', function() return require('opencode').operator('@this ') end, { desc = 'Send range to opencode', expr = true })
        map('n', 'goo', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Send line to opencode', expr = true })
    end,
}
