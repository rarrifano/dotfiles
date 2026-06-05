# Dotfiles

Personal shell, editor, terminal, and pi configuration in a GNU Stow-friendly layout.

## Structure

- `bash/` — Bash config (`.bashrc`, `.bash_aliases`)
- `tmux/` — tmux config (`.tmux.conf`)
- `nvim/` — Neovim config under `.config/nvim/`
- `pi/` — pi sandbox profile and launcher
- `.pi/extensions/` — project-local pi commands

## Highlights

- Bash aliases and helpers for day-to-day shell use
- tmux configured with vi-style copy mode and `M-h/j/k/l` pane navigation
- Neovim split into focused Lua modules loaded from `init.lua`
- Plugin configuration under `nvim/.config/nvim/lua/plugins/`
- Local pi extensions including `/commit` and `/init`
- `pi/.local/bin/pi` runs pi inside a `node:lts` Docker container with the repo mounted at `/workspace`

## Layout

This repo mirrors home-directory targets instead of grouping files by application source. That makes it easy to manage with tools like GNU Stow while keeping each config isolated.

Examples:

- `bash/.bashrc` -> `~/.bashrc`
- `tmux/.tmux.conf` -> `~/.tmux.conf`
- `nvim/.config/nvim/` -> `~/.config/nvim/`
- `pi/.local/bin/pi` -> `~/.local/bin/pi`

## Using with GNU Stow

From the repository root:

```bash
stow bash
stow tmux
stow nvim
stow pi
```

Or install only the pieces you want.

## Notes

- Alt-based pane navigation is kept aligned between tmux and Neovim.
- Formatting in Neovim is configured with `stylua` for Lua and `goimports` for Go.
- The pi sandbox profile lives under `pi/.config/pi-sandbox/agent/`.
