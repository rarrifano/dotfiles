#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
    tmux
    build-essential
    git
    fd-find
    ripgrep
    checkinstall
    cmake
    stow
    podman
    curl
    fzf
    unzip
    fonts-jetbrains-mono
)

echo "==> Updating package index..."
apt-get update -qq

echo "==> Installing packages: ${PACKAGES[*]}"
apt-get install -y --no-install-recommends "${PACKAGES[@]}"

echo "==> Done!"

