return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })
    vim.lsp.enable({ "lua_ls", "terraformls", "yamlls", "dockerls" })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
      end,
    })
  end,
}
