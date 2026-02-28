#!/usr/bin/env bash
# =============================================================================
# setup.sh — Bootstrap a fresh Debian machine from dotfiles
#
# Usage:
#   bash setup.sh                  Full setup (requires gnome-terminal for Gogh)
#   bash setup.sh --ci             Skip Docker and Gogh (for containers / CI)
#   bash setup.sh --skip-docker    Skip Docker CE + rootless setup
#   bash setup.sh --skip-gogh      Skip Gogh gnome-terminal theme
#   bash setup.sh --help           Show this help message
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Flag parsing ─────────────────────────────────────────────────────────────

SKIP_DOCKER=false
SKIP_GOGH=false

for arg in "$@"; do
    case "$arg" in
        --skip-docker) SKIP_DOCKER=true ;;
        --skip-gogh)   SKIP_GOGH=true ;;
        --ci)          SKIP_DOCKER=true; SKIP_GOGH=true ;;
        --help|-h)
            sed -n '2,/^# =====/{ /^# =====/d; s/^# \?//p }' "${BASH_SOURCE[0]}"
            exit 0
            ;;
        *) echo "Unknown flag: $arg (try --help)"; exit 1 ;;
    esac
done

# ── Helpers ──────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

# ── Step 1: Debian packages ─────────────────────────────────────────────────

apt_install() {
    local pkgs=(
        bash-completion
        build-essential
        curl
        git
        libbz2-dev
        libffi-dev
        liblzma-dev
        libreadline-dev
        libsqlite3-dev
        libssl-dev
        stow
        unzip
        wget
        zlib1g-dev
        dconf-cli
        uuid-runtime
    )
    info "Installing Debian packages: ${pkgs[*]}"
    sudo apt-get update -y
    sudo apt-get install -y "${pkgs[@]}"
}

# ── Step 2: Docker CE ───────────────────────────────────────────────────────

install_docker() {
    if dpkg -s docker-ce &>/dev/null; then
        info "Docker CE already installed — skipping"
        return 0
    fi

    info "Installing Docker CE"

    # Remove conflicting packages
    sudo apt-get remove -y \
        docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null || true

    # Prerequisites
    sudo apt-get install -y ca-certificates curl

    # Docker GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Docker apt source (DEB822 format)
    # shellcheck disable=SC1091
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<REPO
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "${VERSION_CODENAME:-bookworm}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
REPO

    sudo apt-get update -y
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-ce-rootless-extras
}

# ── Step 3: Docker rootless ─────────────────────────────────────────────────

setup_docker_rootless() {
    if systemctl --user is-active docker &>/dev/null; then
        info "Docker rootless already running — skipping"
        return 0
    fi

    info "Setting up Docker rootless mode"

    # Rootless prerequisites
    sudo apt-get install -y uidmap dbus-user-session slirp4netns

    # Ensure subuid/subgid entries
    if ! grep -q "^${USER}:" /etc/subuid 2>/dev/null; then
        sudo usermod --add-subuids 100000-165535 "$USER"
    fi
    if ! grep -q "^${USER}:" /etc/subgid 2>/dev/null; then
        sudo usermod --add-subgids 100000-165535 "$USER"
    fi

    # Persist user services after logout
    sudo loginctl enable-linger "$USER"

    # Install rootless daemon (--force allows coexistence with system daemon)
    dockerd-rootless-setuptool.sh install --force
}

# ── Step 4: Stow dotfiles ───────────────────────────────────────────────────

stow_packages() {
    info "Stowing dotfiles"
    for entry in "$DOTFILES_DIR"/*/; do
        local pkg
        pkg="$(basename "$entry")"
        [[ "$pkg" == ".git" ]] && continue
        info "  stow $pkg"
        stow --adopt --restow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
    done
    # --adopt may pull existing files into the repo; discard those changes
    git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true
}

# ── Step 5: mise ─────────────────────────────────────────────────────────────

install_mise() {
    if command -v mise &>/dev/null; then
        info "mise already installed — skipping"
        return 0
    fi

    info "Installing mise"
    curl -fsSL https://mise.jdx.dev/install.sh | bash
}

# ── Step 6: mise tools ──────────────────────────────────────────────────────

mise_install_tools() {
    info "Installing mise-managed tools"

    # mise must be on PATH — npm's shim calls `mise` internally
    export PATH="$HOME/.local/bin:$PATH"

    # Node and uv must be installed first — npm: and pipx: backends depend on them
    info "  Phase 1: node + uv (prerequisites for npm/pipx backends)"
    mise install node --yes
    mise install uv --yes

    info "  Phase 2: all remaining tools"
    mise install --yes
}

# ── Step 7: Bash completions ────────────────────────────────────────────────

install_completions() {
    info "Installing bash completions to /etc/bash_completion.d/"

    # Tools that generate completion scripts
    local -A gen_completions=(
        [kind]="kind completion bash"
        [helm]="helm completion bash"
        [fd]="fd --gen-completions bash"
        [rg]="rg --generate=complete-bash"
    )

    # Activate mise so tools are on PATH
    eval "$(~/.local/bin/mise activate bash)"

    for name in "${!gen_completions[@]}"; do
        if [[ -f "/etc/bash_completion.d/$name" ]]; then
            info "  $name — already exists, skipping"
            continue
        fi
        local cmd="${gen_completions[$name]}"
        info "  $name"
        $cmd | sudo tee "/etc/bash_completion.d/$name" >/dev/null
    done

    # Tools that use complete -C (terraform, aws)
    if [[ ! -f /etc/bash_completion.d/terraform ]]; then
        info "  terraform"
        printf 'complete -C terraform terraform\ncomplete -C terraform tf\n' \
            | sudo tee /etc/bash_completion.d/terraform >/dev/null
    fi

    if [[ ! -f /etc/bash_completion.d/aws ]]; then
        info "  aws"
        printf 'complete -C aws_completer aws\n' \
            | sudo tee /etc/bash_completion.d/aws >/dev/null
    fi

    # Alias completions for kubectl (file already exists from kubectl apt/mise)
    if [[ -f /etc/bash_completion.d/kubectl ]] && \
       ! grep -q '__start_kubectl k' /etc/bash_completion.d/kubectl; then
        info "  kubectl alias (k)"
        printf '\ncomplete -F __start_kubectl k\n' \
            | sudo tee -a /etc/bash_completion.d/kubectl >/dev/null
    fi
}

# ── Step 8: Default editor ──────────────────────────────────────────────────

set_default_editor() {
    local nvim_shim="$HOME/.local/share/mise/shims/nvim"
    if [[ ! -f "$nvim_shim" ]]; then
        warn "nvim shim not found at $nvim_shim — skipping editor setup"
        return 0
    fi

    info "Setting nvim as default editor via update-alternatives"
    sudo update-alternatives --install /usr/bin/editor editor "$nvim_shim" 60
    sudo update-alternatives --set editor "$nvim_shim"
}

# ── Step 9: Gogh Gruvbox Dark ───────────────────────────────────────────────

install_gogh_theme() {
    if ! command -v gnome-terminal &>/dev/null; then
        warn "gnome-terminal not found — skipping Gogh theme"
        return 0
    fi

    info "Installing Gogh Gruvbox Dark theme"

    # Capture profile list before install
    local profiles_before
    profiles_before=$(dconf read /org/gnome/terminal/legacy/profiles:/list 2>/dev/null || echo "[]")

    # Install Gruvbox Dark via Gogh
    TERMINAL=gnome-terminal bash -c "$(wget -qO- https://raw.githubusercontent.com/Gogh-Co/Gogh/master/gogh.sh)" -- "Gruvbox Dark"

    # Detect the newly created profile UUID
    local profiles_after
    profiles_after=$(dconf read /org/gnome/terminal/legacy/profiles:/list 2>/dev/null || echo "[]")

    local new_uuid
    new_uuid=$(comm -13 \
        <(echo "$profiles_before" | tr ",[']" '\n' | sort) \
        <(echo "$profiles_after"  | tr ",[']" '\n' | sort) \
        | grep -v '^$' | head -1 | tr -d "' ")

    if [[ -n "$new_uuid" ]]; then
        info "Setting Gruvbox Dark ($new_uuid) as default profile"
        dconf write /org/gnome/terminal/legacy/profiles:/default "'$new_uuid'"
    else
        warn "Could not detect new Gogh profile UUID — set default manually"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    info "Dotfiles bootstrap starting"
    info "DOTFILES_DIR=$DOTFILES_DIR"
    echo

    # Prompt for sudo once and keep it alive in the background
    sudo -v
    while true; do sudo -n true; sleep 55; kill -0 "$$" || exit; done 2>/dev/null &

    apt_install

    if [[ "$SKIP_DOCKER" == true ]]; then
        info "Skipping Docker (--skip-docker)"
    else
        install_docker
        setup_docker_rootless
    fi

    stow_packages
    install_mise
    mise_install_tools
    install_completions
    set_default_editor

    if [[ "$SKIP_GOGH" == true ]]; then
        info "Skipping Gogh theme (--skip-gogh)"
    else
        install_gogh_theme
    fi

    echo
    info "Bootstrap complete!"
}

main
