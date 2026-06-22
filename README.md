# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── bash/       → ~/.bashrc
├── kitty/      → ~/.config/kitty/
├── nvim/       → ~/.config/nvim/
├── pi/         → ~/.config/pi/  (pi coding agent — skills, prompts, themes)
├── tmux/       → ~/.tmux.conf
├── mise/       → ~/.config/mise/config.toml  (dev toolchain)
└── scripts/
    ├── bootstrap.sh        # full machine setup (packages + stow + mise)
    └── install-packages.sh # apt packages only
```

## Quick start (new machine)

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
```

> Add `--dry-run` to preview all actions without making changes.

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
| `node` (LTS) | pyright, yamlls, jsonls, prettier, bashls |
| `python` | ruff, pyright runtime |
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
