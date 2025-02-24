local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader><A-1>", function() harpoon:list():replace_at(1) end)
vim.keymap.set("n", "<leader><A-2>", function() harpoon:list():replace_at(2) end)
vim.keymap.set("n", "<leader><A-3>", function() harpoon:list():replace_at(3) end)
vim.keymap.set("n", "<leader><A-4>", function() harpoon:list():replace_at(4) end)

vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
