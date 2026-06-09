-- ui

local function gh(repo)
  return "https://github.com/" .. repo
end

local function spec(repo, version)
  return { src = gh(repo), version = version }
end

vim.pack.add({
  spec("lewis6991/gitsigns.nvim", "v2.1.0"),
  spec("tpope/vim-fugitive", "v3.7"),
})
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
