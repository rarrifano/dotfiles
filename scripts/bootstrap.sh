#!/usr/bin/env bash
# bootstrap.sh — full machine setup: packages + stow + mise
# Usage: ./scripts/bootstrap.sh [--dry-run]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

run() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

echo "==> Dotfiles directory: $DOTFILES_DIR"
$DRY_RUN && echo "==> DRY RUN — no changes will be made"

# 1. Packages
echo "==> Installing system packages..."
run bash "$DOTFILES_DIR/scripts/install-packages.sh"

# 2. mise
if ! command -v mise &>/dev/null && [ ! -x "$HOME/.local/bin/mise" ]; then
  echo "==> Installing mise..."
  run curl -sSf https://mise.run | bash
fi

# 3. GNU Stow
STOW_PACKAGES=(bash kitty mise nvim pi tmux)

echo "==> Stowing packages into $HOME..."
for pkg in "${STOW_PACKAGES[@]}"; do
  echo "    stow: $pkg"
  run stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg"
done

# 4. mise install
echo "==> Installing dev toolchain via mise..."
run mise install

echo ""
echo "Bootstrap complete! Open a new shell or: source ~/.bashrc"
