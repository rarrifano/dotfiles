# Dotfiles — Project Context

> Full context is in `./AGENTS.md` at the repo root. Read it first.

## TL;DR

GNU Stow managed. Each top-level dir is a stow package (bash, kitty, mise,
nvim, pi, task, tmux). Symlinks land in `$HOME`.

**Never edit files in `$HOME` directly — always edit here.**

## Stow commands

```bash
stow --restow --target="$HOME" <package>   # apply / re-apply
stow --delete --target="$HOME" <package>   # remove symlinks
```

## pi container

```bash
pi              # launch agent (mounts cwd into container)
pi-build        # rebuild pi-agent:latest image
```

## Toolchain

```bash
mise install    # install all runtimes + LSP servers
mise outdated   # check for updates
```

## Constraints

- No CI, no IaC, no secrets in code
- Do not modify `*.lock` files without being asked
- Do not touch stow-generated symlinks in `$HOME`
- `auth.json` and `sessions/` are gitignored — never expose them
