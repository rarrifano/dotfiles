-- autocmds

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Per-filetype indent overrides
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "python" },
  callback = function()
    vim.o.shiftwidth = 4
    vim.o.tabstop = 4
    vim.o.softtabstop = 4
  end,
})

-- Auto-reload files changed on disk
-- autoread alone only kicks in on a handful of events; checktime forces the check
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Reload file if changed on disk",
  group = vim.api.nvim_create_augroup("auto-reload", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
