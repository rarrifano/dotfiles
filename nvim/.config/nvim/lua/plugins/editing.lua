return {
  -- ── mini.comment: gcc / gc{motion} ───────────────────────────────────────
  {
    "echasnovski/mini.comment",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── mini.surround: sa / sd / sr ───────────────────────────────────────────
  {
    "echasnovski/mini.surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        add            = "sa", -- Add surrounding in Normal and Visual modes
        delete         = "sd", -- Delete surrounding
        replace        = "sr", -- Replace surrounding
        find           = "sf", -- Find surrounding (to the right)
        find_left      = "sF", -- Find surrounding (to the left)
        highlight      = "sh", -- Highlight surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },

  -- ── mini.pairs: auto-pairs ────────────────────────────────────────────────
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ── conform.nvim: format on save ──────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        go         = { "gofmt" },
        python     = { "black" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        terraform  = { "terraform_fmt" },
        yaml       = { "prettier" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        lua        = { "stylua" },
        markdown   = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      -- Install formatters via Mason
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
  },

  -- ── dressing.nvim: float for vim.ui.input / vim.ui.select ────────────────
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        enabled      = true,
        border       = "rounded",
        win_options  = { winblend = 0 },
      },
      select = { enabled = true },
    },
  },

  -- ── mason-conform: auto-install formatters ────────────────────────────────
  {
    "zapling/mason-conform.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "stevearc/conform.nvim",
    },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "black",
        "shfmt",
        "prettier",
        "stylua",
        -- gofmt ships with Go toolchain; terraform_fmt ships with terraform
      },
    },
  },
}
