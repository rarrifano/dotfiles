return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" },
  keys = {
    { "<leader>gs", ":Git<CR>", desc = "Git status" },
  },
}
