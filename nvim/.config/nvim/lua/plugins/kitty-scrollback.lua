-- kitty-scrollback: vim copy mode for kitty terminal

local util = require("util")

vim.pack.add({
	util.spec("mikesmithgh/kitty-scrollback.nvim"),
})

-- only activate when launched by kitty-scrollback kitten
if vim.env.KITTY_SCROLLBACK_NVIM == "true" then
	require("kitty-scrollback").setup()
end
