# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── bash/       → ~/.bashrc, ~/.bash_aliases
├── kitty/      → ~/.config/kitty/kitty.conf
├── mise/       → ~/.config/mise/config.toml   (dev toolchain)
├── nvim/       → ~/.config/nvim/
├── pi/         → ~/.config/pi/                (pi coding agent — skills, prompts, extensions)
└── tmux/       → ~/.tmux.conf
```

## Quick start (new machine)

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
# symlink all packages at once
stow --restow --target="$HOME" bash kitty mise nvim pi tmux
# install dev toolchain
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

| Tool | Purpose |
|------|---------|
| `node` (LTS) | pyright, yamlls, jsonls, prettier, bash-language-server |
| `python` 3.13 | ruff, pyright runtime |
| `go` | personal Go projects |
| `stylua` | Lua formatter |
| `shfmt` | Shell formatter |
| `ruff` | Python formatter + linter |
| `prettier` | YAML / JSON formatter |
| `pyright` | Python LSP |
| `bash-language-server` | Bash LSP |
| `yaml-language-server` | YAML LSP |
| `vscode-langservers-extracted` | JSON LSP |
| `terraform-ls` | Terraform LSP |
| `tflint` | Terraform linter |
| `actionlint` | GitHub Actions linter |
| `lua-language-server` | Lua LSP |
| `usage` | mise task completion + help |

## Neovim

- Plugin manager: `vim.pack` (Neovim 0.11+ native)
- LSP: nvim-lspconfig v2 style (`vim.lsp.config` + `vim.lsp.enable`)
- Fuzzy finder: fzf-lua
- Formatter: conform.nvim (format-on-save)
- Colorscheme: `retrobox` (transparent background)

## Terminal stack

| Layer | Tool |
|-------|------|
| Terminal emulator | Kitty (Wayland native) |
| Multiplexer | tmux |
| Shell | bash |
| Font | JetBrains Mono |
| Colorscheme | Gruvbox Dark (consistent across all layers) |

## pi coding agent

Config lives in `pi/.config/pi/` and symlinks to `~/.config/pi/`.

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Global agent behaviour instructions |
| `APPEND_SYSTEM.md` | System prompt append (Ferris persona) |
| `keybindings.json` | Custom TUI keybindings |
| `extensions/` | Custom pi extensions (`git-checkpoint`, `hide-cursor`) |
| `prompts/` | Reusable prompt templates (`commit`, `pr`, `review`, `debug`, `explain`, `postmortem`, `runbook`, `test`, `tf-plan-review`) |
| `skills/` | Agent skills (`gh-actions`, `gmud-checklist`, `k8s-debug`, `persona-sync`, `tf-workflow`, `user-context`) |
