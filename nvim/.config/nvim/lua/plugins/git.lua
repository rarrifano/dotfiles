return {
  -- ── gitsigns: inline hunk decorations + actions ──────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay        = 300,
        virt_text_pos = "eol",
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end
        local emap = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, expr = true, desc = "Git: " .. desc })
        end

        -- Navigation
        emap("n", "]h", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, "Next hunk")

        emap("n", "[h", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, "Prev hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk,                "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk,                "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk,              "Preview hunk")
        map("n", "<leader>hS", gs.stage_buffer,              "Stage buffer")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hd", gs.diffthis,                  "Diff this")
      end,
    },
  },

  -- ── vim-fugitive: Git command suite ──────────────────────────────────────
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Glog", "Gclog" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>",       desc = "Git status (fugitive)" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
    },
  },
}
