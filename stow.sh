#!/usr/bin/env sh
set -e

DOTFILES=$(cd "$(dirname "$0")" && pwd)

stow --no-folding -t "$HOME" -d "$DOTFILES" bash kitty mise nvim pi
