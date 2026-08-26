-- ~/.config/nvim/init.lua

vim.cmd.colorscheme("retrobox")
vim.cmd.highlight("Normal ctermbg=NONE guibg=NONE")
vim.cmd.highlight("NonText ctermbg=NONE guibg=NONE")

vim.g.mapleader = " "
vim.opt.updatetime = 100

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.path:append("**")

vim.opt.grepprg = "rg --vimgrep --smart-case --no-heading"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.api.nvim_create_user_command("Fd", function(opts)
  local cmd = "fdfind --type f --strip-cwd-prefix"
  if opts.args ~= "" then
    cmd = cmd .. " " .. vim.fn.shellescape(opts.args)
  end
  local files = vim.fn.systemlist(cmd)
  vim.fn.setqflist({}, " ", {
    title = "Fd",
    items = vim.tbl_map(function(f) return { filename = f } end, files),
  })
  vim.cmd("copen")
end, { nargs = "*" })

vim.opt.mouse = "a"
vim.opt.undofile = true

vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprevious<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")
vim.keymap.set("n", "[b", ":bprevious<CR>")

vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>f", ":Fd ")
