# AGENTS.md

## Project scope

- Personal dotfiles/config repo.
- This repository is organized as Stow-style packages: top-level directories mirror home-directory targets rather than app-namespaced source folders.
- Treat paths in the repo as the source of truth for symlinked dotfiles; edit the files in this repo, not resolved paths under `$HOME`.
- Current repo content includes:
  - `bash/` for Bash config
  - `tmux/` for tmux config
  - `nvim/` for Neovim config
  - `pi/` for a pi sandbox profile and launcher
  - `.pi/extensions/` for project-local pi commands

## Important paths

- `bash/.bashrc`
- `bash/.bash_aliases`
- `tmux/.tmux.conf`
- `nvim/.config/nvim/init.lua`
- `nvim/.config/nvim/lua/`
- `nvim/.config/nvim/lua/plugins/`
- `pi/.config/pi-sandbox/agent/AGENTS.md`
- `pi/.config/pi-sandbox/agent/settings.json`
- `pi/.config/pi-sandbox/agent/keybindings.json`
- `pi/.local/bin/pi`
- `.pi/extensions/commit.ts`
- `.pi/extensions/init.ts`

## Repo-specific conventions

- Preserve the Stow-style path layout used by the repo. Edit files in their full target paths, e.g. `nvim/.config/nvim/init.lua`, not flattened aliases.
- Assume files may be deployed via GNU Stow or equivalent symlinks. Do not restructure directories unless the user explicitly asks for a layout change.
- Keep changes scoped to the relevant subtree; this repo is a collection of independent configs.
- Follow the existing style of the file you touch:
  - Bash config uses small aliases/functions, guard clauses, and quoted variables.
  - Neovim config is split into focused Lua modules loaded from `init.lua`.
  - tmux config is a single file with explicit keybindings and terminal settings.
- Alt-based pane navigation is configured in both tmux and Neovim (`M-h/j/k/l`). Keep those mappings aligned if you change either side.

## Neovim notes

- Entry point: `nvim/.config/nvim/init.lua`.
- Core modules loaded first: `options`, `keymaps`, `autocmds`, `diagnostics`.
- Plugin config is separated under `nvim/.config/nvim/lua/plugins/`.
- Formatting configured in `lua/plugins/conform.lua`:
  - `stylua` for Lua
  - `goimports` for Go
- LSP/tool installation is configured in `lua/plugins/lsp.lua` via Mason.

## pi notes

- When a task involves pi settings, keybindings, sandbox agent config, or the launcher, check the `pi/` subtree first.
- Project-local pi commands live in `.pi/extensions/`.
- `commit.ts` registers `/commit`.
- `init.ts` registers `/init`.
- `pi/.local/bin/pi` runs pi inside a `node:lts` Docker container and mounts the current repo at `/workspace`.
- The repo also contains a sandbox agent profile under `pi/.config/pi-sandbox/agent/`.

## Verified commands

- Repo inspection:
  - `find . -maxdepth 5 -type f | sort`
  - `git status --short`
  - `git log --oneline -5`
- Bash syntax check:
  - `bash -n bash/.bashrc bash/.bash_aliases`

## Environment notes

- In the current container, `nvim` and `tmux` binaries were not available, so their configs were inspected statically rather than executed.
- No project-wide build, test, lint, or package manifest files were found at the repo root during inspection.

## Working guidance for future agents

- Read neighboring config modules before making style or keybinding changes.
- When editing Neovim config, check related files under `lua/` and `lua/plugins/` to avoid duplicating behavior.
- When editing shell aliases/functions, preserve the existing confirmation-first pattern for destructive helpers.
- For pi-related changes, inspect `pi/` before looking elsewhere in the repo.
- Do not add commands or workflows to this file unless they are present in the repo or you verified them in the current environment.
