return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    -- Load on demand — don't eat startup time
    keys = {
      {
        "<leader>oc",
        function() require("opencode").toggle() end,
        mode = { "n", "t" },
        desc = "Opencode: Toggle panel",
      },
      {
        "<leader>os",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        mode = { "n", "x" },
        desc = "Opencode: Send selection/context",
      },
    },
    cmd = { "Opencode", "OpencodeAsk", "OpencodeToggle" },
    opts = {
      -- Require: `autoread` so edited buffers reload automatically
      -- (set globally below via init)
    },
    init = function()
      -- Required by opencode.nvim: auto-reload buffers changed on disk
      vim.o.autoread = true
      -- Trigger autoread when focus is gained or a buffer is entered
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
        group = vim.api.nvim_create_augroup("OpencodeAutoread", { clear = true }),
        callback = function()
          if vim.fn.mode() ~= "c" then
            vim.cmd("silent! checktime")
          end
        end,
      })
    end,
  },
}
