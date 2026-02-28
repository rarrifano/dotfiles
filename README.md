# dotfiles

Personal dotfiles for a Debian-based DevOps/SRE workstation. Managed with [GNU Stow](https://www.gnu.org/software/stow/) and [mise](https://mise.jdx.dev/).

## What's included

| Package    | What it configures                                          |
| ---------- | ----------------------------------------------------------- |
| `bash`     | Aliases, prompt, Docker rootless, mise activation           |
| `git`      | User identity, rebase on pull, auto-setup remote            |
| `mise`     | 20 tools: go, node, python, terraform, kubectl, neovim, ... |
| `nvim`     | LSP, Treesitter, Telescope, Copilot, format-on-save         |
| `tmux`     | Vim keys, Gruvbox status bar, Alt+N window switching         |
| `opencode` | OpenCode AI assistant with Copilot provider                 |

## Quick start

### 1. Fork and clone

```bash
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Edit personal settings

```bash
# git/.gitconfig — change name and email
# bash/.bashrc   — review aliases, DOCKER_HOST
```

### 3. Run the bootstrap

```bash
bash setup.sh
```

This is idempotent — safe to re-run. It will:

1. Install base Debian packages
2. Install Docker CE + rootless mode
3. Symlink dotfiles via `stow`
4. Install mise and all managed tools
5. Generate bash completions
6. Set nvim as default editor
7. Install Gruvbox Dark terminal theme (Gogh)

### Flags

```
bash setup.sh --skip-docker    Skip Docker CE + rootless setup
bash setup.sh --skip-gogh      Skip Gogh terminal theme
bash setup.sh --ci             Skip both (for containers / CI)
```

## Adding a new stow package

```bash
mkdir -p foo/.config/foo
# add config files mirroring the $HOME structure
stow --dir=~/dotfiles --target=$HOME foo
```
