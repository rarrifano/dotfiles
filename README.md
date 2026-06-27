# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── bash/       → ~/.bashrc, ~/.bash_aliases
├── kitty/      → ~/.config/kitty/kitty.conf, pass_keys.py
├── mise/       → ~/.config/mise/config.toml   (dev toolchain)
├── nvim/       → ~/.config/nvim/
├── pi/         → ~/.config/pi/                (pi coding agent — skills, prompts, extensions)
├── task/       → ~/.config/task/
└── tmux/       → ~/.tmux.conf
```

## Quick start (new machine)

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The script installs `stow` and `mise` if missing, symlinks all packages, and runs `mise install`. Re-running it is safe.

To do it manually instead:

```bash
stow --restow --target="$HOME" bash kitty mise nvim pi task tmux
mise install
```

## Manual stow

To symlink a single package:

```bash
cd ~/dotfiles
stow --restow --target="$HOME" nvim
```

To remove symlinks for a package:

```bash
stow --delete --target="$HOME" nvim
```

## Dev toolchain

All LSP servers, formatters, and language runtimes are declared in [`mise/.config/mise/config.toml`](./mise/.config/mise/config.toml) and managed by [mise](https://mise.jdx.dev).

```bash
mise install   # install everything
mise outdated  # check for updates
```

| Tool                           | Purpose                                                 |
| ------------------------------ | ------------------------------------------------------- |
| `node` (LTS)                   | pyright, yamlls, jsonls, prettier, bash-language-server |
| `python` 3.13                  | ruff, pyright runtime                                   |
| `go`                           | personal Go projects                                    |
| `stylua`                       | Lua formatter                                           |
| `shfmt`                        | Shell formatter                                         |
| `ruff`                         | Python formatter + linter                               |
| `prettier`                     | YAML / JSON formatter                                   |
| `pyright`                      | Python LSP                                              |
| `bash-language-server`         | Bash LSP                                                |
| `yaml-language-server`         | YAML LSP                                                |
| `vscode-langservers-extracted` | JSON LSP                                                |
| `terraform-ls`                 | Terraform LSP                                           |
| `tflint`                       | Terraform linter                                        |
| `actionlint`                   | GitHub Actions linter                                   |
| `lua-language-server`          | Lua LSP                                                 |
| `usage`                        | mise task completion + help                             |
| `rust` (stable)                | required by mdcat                                       |
| `mdcat` 2.7.1                  | markdown renderer for `pi -p` — kitty graphics protocol |

## Neovim

- Plugin manager: `vim.pack` (Neovim 0.11+ native)
- LSP: nvim-lspconfig v2 style (`vim.lsp.config` + `vim.lsp.enable`)
- Fuzzy finder: fzf-lua
- Formatter: conform.nvim (format-on-save)
- Colorscheme: `retrobox` (transparent background)

## Terminal stack

| Layer             | Tool                                        |
| ----------------- | ------------------------------------------- |
| Terminal emulator | Kitty (Wayland native)                      |
| Multiplexer       | tmux                                        |
| Shell             | bash                                        |
| Font              | Hack                                        |
| Colorscheme       | Gruvbox Dark (consistent across all layers) |

## pi coding agent

Config lives in `pi/.config/pi/` and symlinks to `~/.config/pi/`.

| Path               | Purpose                                                                                                                                                         |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md`        | Global agent behaviour instructions                                                                                                                             |
| `APPEND_SYSTEM.md` | System prompt append (Ferris persona)                                                                                                                           |
| `keybindings.json` | Custom TUI keybindings                                                                                                                                          |
| `extensions/`      | Custom pi extensions (`hide-cursor`, `rewind-footer`, `taskwarrior`)                                                                                           |
| `prompts/`         | Reusable prompt templates (`commit`, `pr`, `review`, `debug`, `explain`, `standup`, `weekly-report`, `postmortem`, `runbook`, `test`, `tf-plan-review`, `init`) |
| `skills/`          | Agent skills (`gh-actions`, `gmud-checklist`, `k8s-debug`, `meeting-prep`, `persona-sync`, `report-builder`, `tf-workflow`, `user-context`)                     |

## Git

Git identity is **not tracked** in this repo — configure it per machine via `~/.gitconfig.local`:

```ini
# ~/.gitconfig.local  (never commit this)
[user]
	name  = Rafael Arrifano
	email = you@example.com

[credential]
	helper = store  # or manager, osxkeychain, etc.
```
