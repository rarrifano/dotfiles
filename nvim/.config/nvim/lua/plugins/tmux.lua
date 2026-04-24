return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      local map = vim.keymap.set

      -- Move between nvim splits and tmux panes seamlessly
      map({ "n", "t" }, "<A-h>", ss.move_cursor_left,  { desc = "Move to left split/pane" })
      map({ "n", "t" }, "<A-j>", ss.move_cursor_down,  { desc = "Move to lower split/pane" })
      map({ "n", "t" }, "<A-k>", ss.move_cursor_up,    { desc = "Move to upper split/pane" })
      map({ "n", "t" }, "<A-l>", ss.move_cursor_right, { desc = "Move to right split/pane" })

      -- Resize splits with Alt+arrows
      map("n", "<A-Left>",  ss.resize_left,  { desc = "Resize split left" })
      map("n", "<A-Down>",  ss.resize_down,  { desc = "Resize split down" })
      map("n", "<A-Up>",    ss.resize_up,    { desc = "Resize split up" })
      map("n", "<A-Right>", ss.resize_right, { desc = "Resize split right" })
    end,
  },
}
