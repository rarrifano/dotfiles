# Dotfiles — Project Context

## Layout
GNU Stow managed. Each top-level dir is a stow package (tmux/, pi/, nvim/, etc.).
Symlinks land in $HOME. Never edit files in $HOME directly — always edit here.

## Stow
- `stow <package>` — link a package
- `stow -D <package>` — unlink
- `stow -R <package>` — relink (after rename/move)

## Pi container
- Launcher: `pi/.local/bin/pi`
- Agent config: `~/.config/pi/` (host) → mounted as `/root/.pi/agent` in container
- Image: `pi-agent:latest` (built separately, not in this repo)

## Never touch
- `*.lock` files without being asked
- Stow-generated symlinks in $HOME
