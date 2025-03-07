local builtin = require('telescope.builtin')

-- Files
vim.keymap.set('n', '<leader>fe', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>ff', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep string' })

-- Zettel
vim.keymap.set('n', '<leader>wn', function() vim.cmd('e ~/Documentos/Zettelkasten/' .. os.date('%Y%m%d%H%M%S') .. '.md') end)
vim.keymap.set('n', '<leader>ww', function() builtin.live_grep({cwd = '~/Documentos/Zettelkasten'}) end, { desc = 'Zettel live grep' })
vim.keymap.set('n', '<leader>we', function() builtin.find_files({cwd = '~/Documentos/Zettelkasten'}) end, { desc = 'Zettel find files' })

-- Settings
vim.keymap.set('n', '<leader>op', function() builtin.find_files({cwd = '~/.config/nvim'}) end, { desc = 'Settings find files' })

-- Buffers
vim.keymap.set('n', '<leader>ee', builtin.buffers, { desc = 'Telescope buffers' })

-- Docs
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Zettel Link
vim.keymap.set('n', '<leader>wl',
function()
    builtin.live_grep({
        prompt_title = "Zettel link file",
        cwd = '~/Documentos/Zettelkasten/',
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                
                local wiki_link = selection.filename
                    :gsub(".*/", "")
                
                vim.api.nvim_put({ "[[" .. wiki_link .. "]]" }, "", false, true)
            end)
            return true
        end
    })
end)
