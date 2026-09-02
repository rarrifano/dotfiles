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
    vim.lsp.config("terraformls", {
      filetypes = { "terraform", "terraform-vars", "hcl" },
    })
    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemas = {
            kubernetes = { "k8s/**/*.yaml", "kubernetes/**/*.yaml", "*.k8s.yaml" },
          },
        },
      },
    })
    vim.lsp.enable({
      "lua_ls",
      "terraformls",
      "yamlls",
      "dockerls",
      "bashls",
      "pyright",
      "gopls",
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
      end,
    })
  end,
}
