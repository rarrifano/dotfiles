# Neovim Cheat Sheet

> `<leader>` = `\` (default)

---

## Navigation

| Key               | Action                            |
| ----------------- | --------------------------------- |
| `<C-d>` / `<C-u>` | Scroll down / up (cursor centred) |
| `n` / `N`         | Next / prev search (centred)      |
| `]b` / `[b`       | Next / prev buffer                |
| `]q` / `[q`       | Next / prev quickfix              |
| `]h` / `[h`       | Next / prev git hunk              |
| `]d` / `[d`       | Next / prev diagnostic            |

---

## Files & Search (fzf-lua)

| Key         | Action                   |
| ----------- | ------------------------ |
| `<leader>f` | Find files               |
| `<leader>/` | Live grep (project-wide) |
| `<leader>b` | Buffers                  |
| `<leader>?` | Recent files             |
| `<leader>e` | File explorer (netrw)    |

---

## LSP

| Key          | Action                     |
| ------------ | -------------------------- |
| `gd`         | Go to definition           |
| `gD`         | Go to declaration          |
| `gI`         | Go to implementation       |
| `gr`         | References (quickfix)      |
| `<leader>r`  | References (fzf picker)    |
| `K`          | Hover docs                 |
| `<C-k>`      | Signature help             |
| `<leader>ca` | Code action                |
| `<leader>rn` | Rename symbol              |
| `<leader>d`  | Document diagnostics (fzf) |
| `<leader>cf` | Format buffer              |

---

## Clipboard

| Key         | Action                            |
| ----------- | --------------------------------- |
| `<leader>y` | Yank to system clipboard (n/v)    |
| `<leader>Y` | Yank line to system clipboard     |
| `<leader>p` | Paste from system clipboard (n/v) |

---

## Git

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>gg` | Fugitive status       |
| `<leader>gd` | Diff (vertical split) |
| `<leader>gb` | Blame line (full)     |
| `<leader>gc` | Git commits (fzf)     |
| `<leader>gs` | Git status (fzf)      |
| `<leader>hs` | Stage hunk            |
| `<leader>hr` | Reset hunk            |
| `<leader>hp` | Preview hunk          |
| `<leader>hS` | Stage buffer          |
| `<leader>hd` | Diff this             |

---

## Editing

| Key / Motion   | Action                         |
| -------------- | ------------------------------ |
| `gcc`          | Toggle comment (line)          |
| `gc{motion}`   | Toggle comment (motion)        |
| `sa{motion}`   | Add surrounding                |
| `sd{motion}`   | Delete surrounding             |
| `sr{old}{new}` | Replace surrounding            |
| `J`            | Join lines (cursor stays)      |
| `<` / `>`      | Indent / dedent (keeps visual) |
| `<leader>R`    | Rename word in file (sed)      |

---

## Buffers & Windows

| Key           | Action                       |
| ------------- | ---------------------------- |
| `<leader>bd`  | Delete buffer                |
| `<C-h/j/k/l>` | Navigate panes (nvim + tmux) |

---

## Debug (DAP)

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start  |
| `<leader>do` | Step over         |
| `<leader>di` | Step into         |
| `<leader>dO` | Step out          |
| `<leader>dq` | Terminate         |
| `<leader>dr` | Toggle REPL       |
| `<leader>du` | Toggle UI         |

---

## Terminal

| Key          | Action                 |
| ------------ | ---------------------- |
| `<Esc><Esc>` | Exit terminal mode     |
| `<Esc>`      | Clear search highlight |
