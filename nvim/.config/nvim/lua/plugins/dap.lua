return {
  -- ── nvim-dap core ────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,  desc = "DAP: Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,           desc = "DAP: Continue / Start" },
      { "<leader>do", function() require("dap").step_over() end,          desc = "DAP: Step over" },
      { "<leader>di", function() require("dap").step_into() end,          desc = "DAP: Step into" },
      { "<leader>dO", function() require("dap").step_out() end,           desc = "DAP: Step out" },
      { "<leader>dq", function() require("dap").terminate() end,          desc = "DAP: Terminate" },
      { "<leader>dr", function() require("dap").repl.toggle() end,        desc = "DAP: Toggle REPL" },
      { "<leader>du", function() require("dapui").toggle() end,           desc = "DAP: Toggle UI" },
    },
    dependencies = {
      -- UI
      { "nvim-neotest/nvim-nio" },
      {
        "rcarriga/nvim-dap-ui",
        opts = {
          icons = { expanded = "v", collapsed = ">", current_frame = ">" },
          controls = {
            icons = {
              pause        = "pause",
              play         = "play",
              step_into    = "into",
              step_over    = "over",
              step_out     = "out",
              step_back    = "back",
              run_last     = "last",
              terminate    = "stop",
              disconnect   = "disc",
            },
          },
          layouts = {
            {
              elements = {
                { id = "scopes",      size = 0.40 },
                { id = "breakpoints", size = 0.20 },
                { id = "stacks",      size = 0.20 },
                { id = "watches",     size = 0.20 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                { id = "repl",    size = 0.50 },
                { id = "console", size = 0.50 },
              },
              size = 12,
              position = "bottom",
            },
          },
          floating = { border = "rounded" },
        },
        config = function(_, opts)
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup(opts)
          -- Auto-open/close UI on session start/end
          dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
        end,
      },
      -- Inline variable values while debugging
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          commented = false,
          virt_text_pos = "eol",
        },
      },
    },
  },

  -- ── mason-nvim-dap: auto-install debug adapters ───────────────────────────
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "delve",              -- Go
        "debugpy",            -- Python
        "bash-debug-adapter", -- Bash
      },
      -- empty handlers = use default automatic adapter setup for all installed
      handlers = {},
    },
  },
}
