#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
ALL_PACKAGES=(bash git mise nvim opencode tmux)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# ── Helpers ──────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PACKAGES...]

Symlink dotfiles into \$HOME using GNU Stow.

Options:
  -D        Unstow (remove symlinks)
  -R        Restow (unstow then stow)
  -n        Dry-run (simulate only)
  -h        Show this help message

Packages: ${ALL_PACKAGES[*]}
If no packages are specified, all packages are processed.
EOF
    exit 0
}

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m!\033[0m  %s\n' "$*"; }
err()   { printf '\033[1;31m✗\033[0m  %s\n' "$*" >&2; }

check_deps() {
    if ! command -v stow &>/dev/null; then
        err "GNU Stow is not installed."
        echo "  Install it with: sudo apt install stow"
        exit 1
    fi
}

backup_conflicts() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    while IFS= read -r -d '' file; do
        local rel="${file#"$pkg_dir"/}"
        local target="$HOME/$rel"

        if [[ -e "$target" && ! -L "$target" ]]; then
            local backup_path="$BACKUP_DIR/$pkg/$rel"
            mkdir -p "$(dirname "$backup_path")"
            mv "$target" "$backup_path"
            warn "Backed up $target → $backup_path"
        fi
    done < <(find "$pkg_dir" -type f -print0)
}

# ── Main ─────────────────────────────────────────────────────────────────────

ACTION="stow"
DRY_RUN=""
STOW_OPTS=("--verbose=1")

while getopts ":DRnh" opt; do
    case $opt in
        D) ACTION="unstow" ;;
        R) ACTION="restow" ;;
        n) DRY_RUN="--simulate"; STOW_OPTS+=("--simulate") ;;
        h) usage ;;
        *) err "Unknown option: -$OPTARG"; usage ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -gt 0 ]]; then
    PACKAGES=("$@")
else
    PACKAGES=("${ALL_PACKAGES[@]}")
fi

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        err "Package '$pkg' not found in $DOTFILES_DIR"
        exit 1
    fi
done

check_deps

info "Dotfiles directory: $DOTFILES_DIR"
info "Action: $ACTION | Packages: ${PACKAGES[*]}${DRY_RUN:+ (dry-run)}"
echo

case "$ACTION" in
    stow)
        for pkg in "${PACKAGES[@]}"; do
            if [[ -z "$DRY_RUN" ]]; then
                backup_conflicts "$pkg"
            fi
            info "Stowing $pkg"
            stow --dir="$DOTFILES_DIR" --target="$HOME" "${STOW_OPTS[@]}" "$pkg"
            ok "$pkg"
        done
        ;;
    unstow)
        for pkg in "${PACKAGES[@]}"; do
            info "Unstowing $pkg"
            stow --dir="$DOTFILES_DIR" --target="$HOME" "${STOW_OPTS[@]}" -D "$pkg"
            ok "$pkg"
        done
        ;;
    restow)
        for pkg in "${PACKAGES[@]}"; do
            if [[ -z "$DRY_RUN" ]]; then
                backup_conflicts "$pkg"
            fi
            info "Restowing $pkg"
            stow --dir="$DOTFILES_DIR" --target="$HOME" "${STOW_OPTS[@]}" -R "$pkg"
            ok "$pkg"
        done
        ;;
esac

echo
ok "Done! All requested packages have been ${ACTION}ed."
if [[ -d "$BACKUP_DIR" ]]; then
    info "Backups saved to: $BACKUP_DIR"
fi
