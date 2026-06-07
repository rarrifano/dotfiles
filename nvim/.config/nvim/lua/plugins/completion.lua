-- completion

local function gh(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = "v2.5.0" } })
require("luasnip").setup({})

vim.pack.add({ { src = gh("saghen/blink.cmp"), version = "v1.10.2" } })
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<Tab>"] = {},
    ["<S-Tab>"] = {},
    ["<CR>"] = {},
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets" },
  },
  snippets = { preset = "luasnip" },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})
