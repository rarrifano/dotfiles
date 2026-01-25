#!/usr/bin/env bash
set -e

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"
echo "[INFO] Backup directory: $BACKUP_DIR"

backup_and_link() {
  local src=$1
  local dest=$2
  local desc=$3
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "[WARN] $desc already exists at $dest; moving to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "[OK] Linked $desc to $dest"
}

echo "[INFO] Installing bashrc..."
backup_and_link "$PWD/bash/.bashrc" "$HOME/.bashrc" ".bashrc"

echo "[INFO] Installing tmux config..."
backup_and_link "$PWD/tmux/.tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"

# Neovim
if [ -d "$PWD/nvim/.config/nvim" ]; then
  echo "[INFO] Installing Neovim config..."
  mkdir -p "$HOME/.config/nvim"
  for file in "$PWD/nvim/.config/nvim"/*; do
    base=$(basename "$file")
    backup_and_link "$file" "$HOME/.config/nvim/$base" "nvim/$base"
  done
fi

echo "[DONE] Dotfiles installed. You may want to restart your shell."
