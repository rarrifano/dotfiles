# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a stow package mirroring `$HOME`. **Config repo only** — no
tests, no build artifacts, no dependencies beyond `stow`.

### Stow Packages

| Package    | Key Files                                               |
|------------|---------------------------------------------------------|
| `bash`     | `.bashrc`                                               |
| `git`      | `.gitconfig`                                            |
| `mise`     | `.config/mise/config.toml`                              |
| `nvim`     | `.config/nvim/init.lua`, `lua/`, `lua/plugins/`        |
| `opencode` | `.config/opencode/opencode.jsonc`                       |
| `tmux`     | `.tmux.conf`                                            |

## Commands

```bash
# Stow all packages / single package / unstow / restow / dry-run
./install.sh
./install.sh nvim
./install.sh -D nvim
./install.sh -R nvim
./install.sh -n          # dry-run — always run before real changes

# Validate before committing
bash -n install.sh
shellcheck install.sh
shellcheck bash/.bashrc
luacheck nvim/.config/nvim/
taplo check mise/.config/mise/config.toml
```

**Formatters**: `shfmt` (shell) · `stylua` (Lua) · `taplo` (TOML) · `prettier` (YAML/JSON/MD) · `black` (Python) · `terraform_fmt` (HCL)

## Critical Agent Rules

1. **Symlinks are live**: files here are symlinked into `$HOME`. Edits take effect immediately; re-stow is only needed when adding new files.
2. **Stow path mirrors `$HOME`**: `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`. Never break this structure.
3. **Adding a new plugin**: create `nvim/.config/nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec table. **Do NOT edit `lazy_setup.lua`** — it uses `require("lazy").setup("plugins", …)` which auto-discovers every `.lua` file in `lua/plugins/`.
4. **Adding a new stow package**: create the top-level directory mirroring `$HOME`, then add the package name to `ALL_PACKAGES` in `install.sh`.
5. **Never commit secrets**: no `.env` files, tokens, or credentials.
6. **`backup_conflicts`** in `install.sh` moves conflicting non-stow files to `~/.dotfiles-backup/<timestamp>/` — it is skipped on dry-run (`-n`).

## Code Style

### Shell (`bash`)

- Shebang `#!/usr/bin/env bash`, `set -euo pipefail` at top (scripts only — not `.bashrc`)
- Quote all variables; `[[ ]]` for conditionals; `$(...)` not backticks
- Output helpers: `info()`, `ok()`, `warn()`, `err()` (defined in `install.sh`)
- `getopts` for option parsing; `local` for all function variables; 4-space indent

### Lua (Neovim)

- 4-space indent; single-quoted strings; `require('module.name')` paths
- Every plugin file lives under `lua/plugins/`, returns one lazy.nvim spec table
- Core modules (`options.lua`, `keymaps.lua`, `autocmds.lua`) live directly in `lua/` — there is no `lua/core/` subdirectory
- Keymaps: always include `desc`; buffer-local keymaps go in `on_attach`/`LspAttach`
- Lazy-load with `event`, `cmd`, `keys`, or `ft`
- Start each file with a comment describing its purpose; no trailing whitespace

### TOML / JSONC

- TOML: prefer explicit versions (not `"latest"`) for reproducibility, entries under named tables
- JSONC: section divider comments `// -- Section Name --`

## Nvim Plugin Index

`lazy_setup.lua` auto-discovers all files in `lua/plugins/` — this table is the authoritative list:

| File             | Purpose                                                     |
|------------------|-------------------------------------------------------------|
| `dap.lua`        | Debug adapters (nvim-dap, dap-ui, mason-nvim-dap; Go/Python/Bash) |
| `editing.lua`    | mini.comment, mini.surround, mini.pairs, conform (format-on-save) |
| `fzf.lua`        | Fuzzy finder (fzf-lua — **not** Telescope)                  |
| `git.lua`        | Gitsigns + Fugitive                                         |
| `lsp.lua`        | LSP servers (Mason + lspconfig)                             |
| `opencode.lua`   | OpenCode AI integration                                     |
| `tmux.lua`       | Navigator.nvim — nvim/tmux pane nav                         |
| `treesitter.lua` | Syntax highlighting                                         |
| `ui.lua`         | Gruvbox dark theme + lualine statusline                     |

## Commit Convention

`type(scope): description` — [Conventional Commits](https://www.conventionalcommits.org/)

- **Types**: `feat`, `fix`, `refactor`, `docs`, `chore`, `revert`
- **Scopes**: package name (`nvim`, `bash`, `git`, `tmux`, `mise`, `opencode`) or `install`
- Imperative mood, lowercase, no trailing period

## OpenCode Config Notes

- `opencode.jsonc` references `CONTRIBUTING.md`, `.cursor/rules/*.md`, and `.github/copilot-instructions.md` in `instructions` — these files do not exist; OpenCode silently skips missing paths. Creating them will cause them to be auto-loaded.
- Snapshots enabled (`"snapshot": true`) — `/undo` works reliably.
- Provider locked to `github-copilot`; model `github-copilot/claude-sonnet-4-5`.
- Destructive commands (`terraform destroy`, `kubectl delete`, `rm -rf`, etc.) require confirmation (`"ask"`); `git push --force` and pipe-to-shell are denied.
- MCP servers (github, context7, gh_grep) are defined but commented out — disabled by default.
