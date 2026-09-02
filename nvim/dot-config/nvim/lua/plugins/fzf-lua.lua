return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  opts = {},
  keys = {
    { "<leader>f", function() require("fzf-lua").files() end, desc = "Find files" },
    { "<leader>g", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
    { "<leader>b", function() require("fzf-lua").buffers() end, desc = "Buffers" },
  },
}
