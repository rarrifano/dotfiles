-- ui

local function gh(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
require("guess-indent").setup({})

vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
require("gitsigns").setup()

vim.cmd.colorscheme("retrobox")

-- transparent background
local function set_transparent_bg()
  local groups = {
    "Normal", "NormalNC", "NormalFloat",
    "SignColumn", "FloatBorder",
    "StatusLine", "StatusLineNC",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

set_transparent_bg()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent_bg,
})
