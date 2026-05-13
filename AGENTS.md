# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Structure (GNU Stow)

This is a **config-only** repository. Top-level directories mirror `$HOME`.
- `nvim/` -> `~/.config/nvim/`
- `bash/` -> `~/.bashrc`
- `mise/` -> `~/.config/mise/`
- `git/`, `tmux/`, `opencode/`

**Critical Rule**: Never break the Stow path structure. `nvim/.config/nvim/init.lua` is correct; `nvim/init.lua` is wrong.

## Execution & Workflow

- **Symlinks are live**: Edits here take effect immediately in `$HOME`.
- **Dry-run first**: Always run `./install.sh -n <package>` before applying changes.
- **Adding files**: New files require a re-stow: `./install.sh -R <package>`.
- **Adding plugins**: Create `nvim/.config/nvim/lua/plugins/<name>.lua`. It must return a lazy.nvim spec table. **Do not** edit `lazy_setup.lua`.
- **Formatting/Linting**: Tools like `stylua`, `luacheck`, and `shellcheck` may not be available in the environment; verify existence before attempting to use them.

## Keymaps & Style

### Neovim
- **No Emojis**: Always disable icons/emojis in plugin configs (see `which-key.lua`).
- **Indentation**: 4-space indent for Lua and Shell.
- **Clipboard**: System clipboard access requires `"+` or `"*` registers; it is not set as default. Use `<leader>y` and `<leader>p`.
- **Fzf-lua**: Use `<leader>f` (files) and `<leader>/` (grep). We do **not** use Telescope.

### Shell
- Shebang: `#!/usr/bin/env bash` (scripts only).
- Use `info()`, `ok()`, `warn()`, `err()` helpers from `install.sh`.

## Commit Convention

Format: `type(scope): description`
- **Types**: `feat`, `fix`, `refactor`, `docs`, `chore`.
- **Scopes**: Package name (`nvim`, `bash`, `git`, etc.) or `install`.
- **Style**: Imperative mood, lowercase, no trailing period.

## OpenCode Context
- `AGENTS.md` is the primary instruction source.
- `/undo` is reliable (snapshots enabled).
- Destructive commands require user confirmation.
