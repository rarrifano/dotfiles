-- GitHub Copilot (completions via nvim-cmp)
return {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
    },
}
