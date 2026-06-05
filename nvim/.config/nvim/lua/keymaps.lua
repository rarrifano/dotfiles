-- keymaps

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic location list" })
vim.keymap.set("n", "<leader>e", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.uv.cwd()
  end
  vim.cmd.Ex(dir)
end, { desc = "Open file explorer at current buffer" })
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Fugitive status" })

local function center_horizontally()
  local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local width = vim.api.nvim_win_get_width(0) - info.textoff
  if width <= 0 then
    return
  end

  local view = vim.fn.winsaveview()
  view.leftcol = math.max(0, vim.fn.virtcol(".") - math.floor(width / 2) - 1)
  vim.fn.winrestview(view)
end

local function scroll_and_center(keys)
  return function()
    local count = vim.v.count > 0 and tostring(vim.v.count) or ""
    vim.cmd.normal({ args = { count .. vim.keycode(keys) }, bang = true })
    vim.cmd.normal({ args = { "zz" }, bang = true })
    center_horizontally()
  end
end

vim.keymap.set("n", "<C-d>", scroll_and_center("<C-d>"), { desc = "Scroll down and center cursor" })
vim.keymap.set("n", "<C-u>", scroll_and_center("<C-u>"), { desc = "Scroll up and center cursor" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

local function navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. dir)
  if vim.api.nvim_get_current_win() ~= win then
    return
  end

  if not vim.env.TMUX then
    return
  end

  local map = { h = "L", j = "D", k = "U", l = "R" }
  vim.system({ "tmux", "select-pane", "-" .. map[dir] })
end

vim.keymap.set("n", "<A-h>", function() navigate("h") end)
vim.keymap.set("n", "<A-j>", function() navigate("j") end)
vim.keymap.set("n", "<A-k>", function() navigate("k") end)
vim.keymap.set("n", "<A-l>", function() navigate("l") end)
