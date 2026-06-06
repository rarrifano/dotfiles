-- diagnostics

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = false,
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  desc = "Show line diagnostics in a float",
  group = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
  callback = function(args)
    local diagnostics = vim.diagnostic.get(args.buf, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
    if vim.tbl_isempty(diagnostics) then
      return
    end

    vim.diagnostic.open_float({
      bufnr = args.buf,
      scope = "cursor",
      focus = false,
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave" },
    })
  end,
})

