-- conform

local util = require("util")

vim.pack.add({ { src = util.gh("stevearc/conform.nvim"), version = "v9.1.0" } })

require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == "lua" then
      return { timeout_ms = 500 }
    end
  end,
  default_format_opts = {},
  formatters_by_ft = {
    lua        = { "stylua" },
    python     = { "ruff_format" },
    sh         = { "shfmt" },
    bash       = { "shfmt" },
    yaml       = { "prettier" },
    json       = { "prettier" },
    terraform  = { "terraform_fmt" },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "[C]ode [F]ormat buffer" })
