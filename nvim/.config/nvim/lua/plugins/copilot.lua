-- GitHub Copilot inline suggestions
return {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = {
        suggestion = {
            enabled = true,
            auto_trigger = true,
            keymap = {
                accept = '<C-l>',
                next = '<M-]>',
                prev = '<M-[>',
                dismiss = '<C-e>',
            },
        },
        panel = { enabled = false },
    },
}
