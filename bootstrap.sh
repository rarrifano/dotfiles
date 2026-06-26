#!/usr/bin/env bash
# Bootstrap a new machine: install stow + mise, then symlink all dotfile packages.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STOW_PACKAGES=(bash kitty mise nvim pi scripts task tmux)

log()  { printf '\e[1;32m==>\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m  ->\e[0m %s\n' "$*"; }

# Install stow if missing
if ! command -v stow &>/dev/null; then
  log "Installing stow..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y stow
  elif command -v brew &>/dev/null; then
    brew install stow
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm stow
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y stow
  else
    echo "ERROR: cannot install stow — unsupported package manager. Install it manually then re-run." >&2
    exit 1
  fi
else
  warn "stow already installed: $(stow --version | head -1)"
fi

# Install mise if missing
if ! command -v mise &>/dev/null && [ ! -x "$HOME/.local/bin/mise" ]; then
  log "Installing mise..."
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
else
  warn "mise already installed: $(mise --version)"
fi

# Symlink all packages
log "Stowing dotfile packages..."
cd "$DOTFILES_DIR"
stow --restow --target="$HOME" "${STOW_PACKAGES[@]}"
warn "Symlinks created for: ${STOW_PACKAGES[*]}"

# Install dev toolchain
log "Installing dev toolchain via mise..."
mise install

log "Done! Open a new shell or run: source ~/.bashrc"
