-- ~/.config/nvim/lua/commands.lua

vim.api.nvim_create_user_command("Fd", function(opts)
  local cmd = "fdfind --type f --strip-cwd-prefix"
  if opts.args ~= "" then
    cmd = cmd .. " " .. vim.fn.shellescape(opts.args)
  end
  local files = vim.fn.systemlist(cmd)
  if #files == 1 then
    vim.cmd.edit(files[1])
    return
  end
  vim.fn.setqflist({}, " ", {
    title = "Fd",
    items = vim.tbl_map(function(f) return { filename = f } end, files),
  })
  vim.cmd("copen")
end, { nargs = "*" })

vim.api.nvim_create_user_command("Rg", function(opts)
  local cmd = "rg --vimgrep --smart-case --no-heading " .. vim.fn.shellescape(opts.args)
  local lines = vim.fn.systemlist(cmd)
  vim.fn.setqflist({}, " ", {
    title = "Rg",
    lines = lines,
    efm = vim.o.grepformat,
  })
  vim.cmd("copen")
end, { nargs = "*" })
