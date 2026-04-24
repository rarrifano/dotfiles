# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package    | Key Files                                          |
|------------|----------------------------------------------------|
| `bash`     | `.bashrc`                                          |
| `git`      | `.gitconfig`                                       |
| `mise`     | `.config/mise/config.toml`                         |
| `nvim`     | `.config/nvim/` (Neovim + lazy.nvim)               |
| `opencode` | `.config/opencode/opencode.jsonc`                  |
| `tmux`     | `.tmux.conf`                                       |

## Install

```bash
# Prerequisites: GNU Stow
sudo apt install stow   # Debian/Ubuntu
brew install stow       # macOS

# Clone
git clone https://github.com/rarrifano/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Dry-run first (always)
./install.sh -n

# Stow everything
./install.sh

# Stow a single package
./install.sh nvim

# Unstow / restow
./install.sh -D nvim
./install.sh -R nvim
```

Conflicting files that are not already stow-managed are automatically backed up to `~/.dotfiles-backup/<timestamp>/` before symlinking.

## Neovim

Built on [lazy.nvim](https://github.com/folke/lazy.nvim). Plugins auto-discovered from `nvim/.config/nvim/lua/plugins/`.

**LSP servers** (installed via Mason): `gopls`, `pyright`, `bashls`, `terraformls`, `tflint`, `dockerls`, `yamlls`, `jsonls`, `lua_ls`.

**Key bindings highlights:**

| Key             | Action                              |
|-----------------|-------------------------------------|
| `<leader>r`     | Find all usages / LSP references    |
| `<leader>/`     | Live grep across project            |
| `<leader>f`     | Find files                          |
| `<leader>d`     | Document diagnostics                |
| `<leader>y/p`   | Yank / paste to system clipboard    |
| `gd`            | Go to definition                    |
| `K`             | Hover docs                          |
| `<leader>ca`    | Code action                         |
| `<leader>rn`    | Rename symbol                       |

Full keymap reference in [`AGENTS.md`](AGENTS.md#nvim-keymap-reference).

## Structure

```
dotfiles/
├── bash/       → ~/.bashrc
├── git/        → ~/.gitconfig
├── install.sh  # stow wrapper
├── mise/       → ~/.config/mise/
├── nvim/       → ~/.config/nvim/
├── opencode/   → ~/.config/opencode/
└── tmux/       → ~/.tmux.conf
```

Each directory mirrors `$HOME` — Stow creates symlinks one level up from the package root.
