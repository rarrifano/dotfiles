-- keymaps

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

local function navigate(dir)
  local win = vim.fn.winnr()
  vim.cmd("wincmd " .. dir)
  if vim.fn.winnr() == win then
    local map = { h = "L", j = "D", k = "U", l = "R" }
    vim.fn.system("tmux select-pane -" .. map[dir])
  end
end

vim.keymap.set("n", "<A-h>", function() navigate("h") end)
vim.keymap.set("n", "<A-j>", function() navigate("j") end)
vim.keymap.set("n", "<A-k>", function() navigate("k") end)
vim.keymap.set("n", "<A-l>", function() navigate("l") end)
