-- conform

local function gh(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({ { src = gh("stevearc/conform.nvim"), version = "v9.1.0" } })

require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      lua    = true,
      go     = true,
      python = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    end
  end,
  default_format_opts = {
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "goimports" }, -- organises imports + formats
    python = { "ruff_organize_imports", "ruff_format" },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "[F]ormat buffer" })
