local map = vim.keymap.set

-- ── Sane defaults ─────────────────────────────────────────────────────────────

-- Keep selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Join lines but keep cursor position
map("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })

-- Keep cursor centred when jumping / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ── Clipboard ─────────────────────────────────────────────────────────────────
-- Explicit yank to system clipboard (clipboard option is intentionally unset)
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Paste without overwriting register
map("x", "<leader>p", '"_dP', { desc = "Paste without yank" })

-- Delete to blackhole (don't pollute yank register)
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to blackhole" })

-- ── Quickfix ──────────────────────────────────────────────────────────────────
map("n", "]q", ":cnext<CR>zz", { desc = "Next quickfix" })
map("n", "[q", ":cprev<CR>zz", { desc = "Prev quickfix" })

-- ── Buffers ───────────────────────────────────────────────────────────────────
map("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
map("n", "[b", ":bprev<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- ── Netrw file explorer ───────────────────────────────────────────────────────
map("n", "<leader>e", ":Explore<CR>", { desc = "File explorer (netrw)" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Project-wide rename word under cursor ─────────────────────────────────────
map("n", "<leader>R", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Rename word in file" })
