-- keymaps

local function reload_config()
  local modules = { "options", "keymaps", "autocmds", "diagnostics" }
  for _, module in ipairs(modules) do
    package.loaded[module] = nil
  end

  for name, _ in pairs(package.loaded) do
    if name:match("^plugins%.") then
      package.loaded[name] = nil
    end
  end

  local ok, err = pcall(dofile, vim.fn.stdpath("config") .. "/init.lua")
  if ok then
    vim.notify("Neovim config reloaded", vim.log.levels.INFO)
    return
  end

  vim.notify("Failed to reload config:\n" .. err, vim.log.levels.ERROR)
end

vim.api.nvim_create_user_command("ReloadConfig", reload_config, { desc = "Reload Neovim config" })

-- Python modern script runner and test runner commands
local function run_python()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file active to run!", vim.log.levels.WARN)
    return
  end
  vim.cmd("split | terminal uv run " .. vim.fn.shellescape(file))
  vim.cmd("startinsert")
end

local function test_python()
  local file = vim.fn.expand("%:t")
  local cmd = "uv run pytest"
  if file:match("^test_.*%.py$") or file:match("^.*_test%.py$") then
    cmd = cmd .. " " .. vim.fn.shellescape(vim.fn.expand("%:p"))
  end
  vim.cmd("split | terminal " .. cmd)
  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("RunPython", run_python, { desc = "Run current Python script with uv" })
vim.api.nvim_create_user_command("TestPython", test_python, { desc = "Run Python tests with uv run pytest" })

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

-- Save & reload
vim.keymap.set("n", "<leader>w",  "<cmd>w<CR>",     { desc = "Save file" })
vim.keymap.set("n", "<leader>q",  "<cmd>bd<CR>",    { desc = "Close buffer" })
vim.keymap.set("n", "<leader>R",  "<cmd>ReloadConfig<CR>", { desc = "Reload Neovim config" })

-- Clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard after" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from clipboard before" })
