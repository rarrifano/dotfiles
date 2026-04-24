return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<cmd>FzfLua files<cr>",            desc = "Find files" },
      { "<leader>/", "<cmd>FzfLua live_grep<cr>",        desc = "Live grep" },
      { "<leader>b", "<cmd>FzfLua buffers<cr>",          desc = "Buffers" },
      { "<leader>r", "<cmd>FzfLua lsp_references<cr>",   desc = "LSP references" },
      { "<leader>?", "<cmd>FzfLua oldfiles<cr>",         desc = "Recent files" },
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>",     desc = "Git commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>",      desc = "Git status" },
      { "<leader>d", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
      { "<leader>*", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Grep selected text" },
    },
    opts = {
      winopts = {
        height  = 0.85,
        width   = 0.85,
        row     = 0.35,
        col     = 0.50,
        border  = "rounded",
        preview = {
          border     = "rounded",
          scrollbar  = false,
          layout     = "flex",
          flip_columns = 120,
        },
      },
      fzf_opts = {
        ["--ansi"]   = true,
        ["--info"]   = "inline",
        ["--height"] = "100%",
        ["--layout"] = "reverse",
      },
      files = {
        -- respect .gitignore by default
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
      },
    },
  },
}
