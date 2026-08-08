#!/usr/bin/env sh
set -e

DOTFILES=$(cd "$(dirname "$0")" && pwd)

stow --no-folding -t "$HOME" -d "$DOTFILES" bash gnupg kitty mise nvim pi
