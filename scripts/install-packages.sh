#!/usr/bin/env bash
# install-packages.sh — apt packages only
# Safe to run multiple times (idempotent)
set -euo pipefail

PACKAGES=(
  git curl wget stow tmux fzf fd-find ripgrep eza jq
  bash-completion build-essential ca-certificates unzip podman
)

echo "==> Updating package list..."
sudo apt-get update -qq

echo "==> Installing packages..."
sudo apt-get install -y --no-install-recommends "${PACKAGES[@]}"

echo "==> Done."
