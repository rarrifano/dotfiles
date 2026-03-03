# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

This is a **personal dotfiles repository** managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a stow package whose contents mirror `$HOME`. Stow creates
symlinks from `$HOME` into this repo. **This is a config repo, not an application** — there
are no tests, no dependencies (beyond stow), and no build artifacts.

### Stow Packages

| Package    | Description                        | Key Files                                    |
|------------|------------------------------------|----------------------------------------------|
| `bash`     | Bash shell configuration           | `.bashrc`                                    |
| `git`      | Global Git configuration           | `.gitconfig`                                 |
| `mise`     | mise tool version manager          | `.config/mise/config.toml`                   |
| `nvim`     | Neovim IDE configuration (Lua)     | `.config/nvim/init.lua`, `lua/core/`, `lua/plugins/` |
| `opencode` | OpenCode AI assistant config       | `.config/opencode/opencode.jsonc`            |
| `tmux`     | tmux terminal multiplexer config   | `.tmux.conf`                                 |

## Build / Lint / Test Commands

```bash
# Symlink all packages into $HOME
./install.sh
# Stow a single package / unstow / restow / dry-run
./install.sh nvim
./install.sh -D nvim
./install.sh -R nvim
./install.sh -n          # dry-run (simulate only)

# Validate shell scripts
bash -n install.sh
shellcheck install.sh
shellcheck bash/.bashrc

# Validate Lua syntax
luacheck nvim/.config/nvim/

# Validate TOML
taplo check mise/.config/mise/config.toml

# Check for stow conflicts without making changes
./install.sh -n
```

### Formatters (configured in `nvim/.config/nvim/lua/plugins/conform.lua`)

Shell: `shfmt` · Lua: `stylua` · TOML: `taplo` · YAML/JSON/Markdown: `prettier` ·
Python: `black` · HCL/Terraform: `terraform_fmt`

## Code Style Guidelines

### Shell Scripts (bash)

- Shebang: `#!/usr/bin/env bash`
- Always set `set -euo pipefail` at the top
- Quote all variables: `"$var"`, not `$var`
- Use `[[ ]]` for conditionals, `$(command)` for substitution (no backticks)
- Helper functions for output: `info()`, `ok()`, `warn()`, `err()`
- Use `getopts` for option parsing; `local` for all function variables
- Indent with 4 spaces

### Lua (Neovim config)

- **Indentation**: 4 spaces
- **Strings**: Single quotes (`'string'`) consistently
- **Requires**: `require('module.name')` with single-quoted dot-separated paths
- **Plugin specs**: One file per plugin under `lua/plugins/`, returns a lazy.nvim spec table
- **Keymaps**: `vim.keymap.set(mode, lhs, rhs, { desc = 'Description' })` — always include `desc`
- **Local aliases**: Assign at top of file (e.g., `local map = vim.keymap.set`)
- **Comments**: Start each file with a single-line comment describing its purpose
- **Buffer-local keymaps**: Set in `on_attach`/`LspAttach` callbacks with `{ buffer = bufnr }`
- **Lazy loading**: Use `event`, `cmd`, `keys`, or `ft` to lazy-load plugins
- No trailing whitespace

### TOML / JSONC / Git

- **TOML**: Group entries under tables (`[tools]`); use explicit versions, not `"latest"`
- **JSONC**: Use section divider comments (`// -- Section Name --`)
- **Git**: `zdiff3` conflict style, `histogram` diff, `pull.rebase = true`, `push.autoSetupRemote = true`

## Naming Conventions

- **Stow packages**: Lowercase, single-word directory names (`bash`, `git`, `nvim`)
- **Lua plugin files**: Lowercase, descriptive (`lsp.lua`, `colorscheme.lua`)
- **Lua modules**: `core/` (options, keymaps) and `plugins/` (one file per plugin)

## Commit Message Convention

[Conventional Commits](https://www.conventionalcommits.org/) format: `type(scope): description`

- **Types**: `feat`, `fix`, `refactor`, `docs`, `chore`, `revert`
- **Scopes**: stow package name (`nvim`, `bash`, `git`, `tmux`, `mise`, `opencode`)
  or `install` for the install script
- **Description**: Imperative mood, lowercase, no trailing period

```
feat(nvim): show hidden files by default in oil.nvim
fix(install): prevent backup_conflicts from deleting stow-managed files
```

## Error Handling

- Shell: Rely on `set -euo pipefail`; use `err()` helper followed by `exit 1`
- Validate preconditions early (e.g., `check_deps` verifies stow is installed)
- Back up conflicting files before overwriting (see `backup_conflicts` in `install.sh`)

## Directory Structure

```
dotfiles/
  install.sh                    # Stow orchestrator script
  bash/.bashrc
  git/.gitconfig
  mise/.config/mise/config.toml
  nvim/.config/nvim/
    init.lua                    # Entry point: bootstrap lazy.nvim, load core + plugins
    lua/core/
      options.lua               # Neovim options
      keymaps.lua               # Global keymaps
    lua/plugins/
      lazy_setup.lua            # Plugin spec aggregator
      lsp.lua                   # LSP servers (Mason + lspconfig)
      telescope.lua             # Fuzzy finder
      treesitter.lua            # Syntax highlighting
      cmp.lua                   # Completion engine
      copilot.lua               # GitHub Copilot
      conform.lua               # Auto-formatting
      git.lua                   # Gitsigns + Fugitive
      oil.lua                   # File browser
      autopairs.lua             # Auto bracket pairing
      snippets.lua              # DevOps snippet library
      colorscheme.lua           # Gruvbox dark theme
      opencode.lua              # OpenCode AI integration
  opencode/.config/opencode/opencode.jsonc
  tmux/.tmux.conf
```

## Important Notes for Agents

1. **Symlink awareness**: Files here are symlinked into `$HOME`. Editing them edits the
   live config. Be cautious with destructive changes.
2. **Stow structure matters**: Each package mirrors `$HOME`. A file at
   `nvim/.config/nvim/init.lua` becomes `~/.config/nvim/init.lua`. Do not break this.
3. **Adding a new plugin**: Create a file in `nvim/.config/nvim/lua/plugins/`, return a
   lazy.nvim spec, and add `require('plugins.<name>')` to `lazy_setup.lua`.
4. **Adding a new stow package**: Create a top-level directory mirroring `$HOME` paths,
   then add the package name to `ALL_PACKAGES` in `install.sh`.
5. **Never commit secrets**: No `.env` files, tokens, or credentials.
6. **Validate before committing**: Run `bash -n install.sh` and `./install.sh -n`.
