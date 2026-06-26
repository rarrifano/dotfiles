# Project Context — dotfiles

## Overview

Personal dotfiles for Rafael Arrifano, managed with **GNU Stow**. Each top-level
directory is a Stow package that symlinks into `$HOME`. The repo is the single
source of truth for the entire dev environment: shell, editor (Neovim 0.12+),
terminal multiplexer (tmux), terminal emulator (Kitty), the pi coding-agent
config, and the task management (Taskwarrior) config. The pi agent itself runs
inside a Podman container (`pi-agent:latest`) built by `pi/.local/bin/pi-build`;
its config is mounted from the host at `~/.config/pi/` (symlinked from
`pi/.config/pi/`).

---

## Stack

- **Shell:** Bash — `.bashrc` + `.bash_aliases` in `bash/`
- **Editor:** Neovim 0.12+ — native plugin API (`vim.pack`), native LSP
  (`vim.lsp.config` / `vim.lsp.enable`), fzf-lua, conform.nvim (format-on-save)
- **Terminal:** Kitty (Wayland native) + tmux multiplexer
- **Toolchain manager:** [mise](https://mise.jdx.dev) — declares all runtimes,
  LSP servers, and formatters in `mise/.config/mise/config.toml`
- **Dotfile manager:** GNU Stow — symlinks each package dir into `$HOME`
- **Coding agent:** pi (`@earendil-works/pi-coding-agent`) running inside a
  Podman container; launcher at `pi/.local/bin/pi`
- **Task management:** Taskwarrior — config in `task/.config/task/`
- **Languages in config files:** Lua (Neovim), Bash, TypeScript (pi extensions),
  TOML (mise), JSON (pi settings / keybindings)

---

## Repository Layout

```
dotfiles/
├── bash/
│   ├── .bashrc            # Main shell config, prompt, history, env
│   └── .bash_aliases      # Aliases (git, kubectl, k9s, docker, misc)
├── kitty/
│   └── .config/kitty/kitty.conf
├── mise/
│   └── .config/mise/config.toml   # All runtimes + LSP/formatter declarations
├── nvim/
│   └── .config/nvim/
│       ├── init.lua               # Entry point: loads lua/* modules
│       └── lua/
│           ├── options.lua        # vim.opt settings
│           ├── keymaps.lua        # All keybindings
│           ├── autocmds.lua       # Autocommands
│           ├── diagnostics.lua    # LSP diagnostic config
│           ├── util.lua           # Shared helpers
│           └── plugins/
│               ├── lsp.lua        # LSP server setup (vim.lsp.config style)
│               ├── conform.lua    # Formatter config (format-on-save)
│               ├── fzf.lua        # fzf-lua picker config
│               └── ui.lua         # Colorscheme + UI plugins
├── pi/
│   ├── .config/pi/
│   │   ├── AGENTS.md              # Global agent behaviour rules
│   │   ├── APPEND_SYSTEM.md       # Ferri-chan persona system prompt append
│   │   ├── settings.json          # pi settings (model, theme, extensions…)
│   │   ├── keybindings.json       # TUI keybindings
│   │   ├── extensions/            # TypeScript pi extensions
│   │   │   ├── hide-cursor.ts     # Hide hardware cursor in TUI
│   │   │   └── taskwarrior.ts     # Taskwarrior tool integration
│   │   ├── prompts/               # Reusable /prompt templates
│   │   │   ├── commit.md          # Conventional commit message
│   │   │   ├── pr.md              # PR description
│   │   │   ├── review.md          # Code review
│   │   │   ├── debug.md           # Debugging guide
│   │   │   ├── explain.md         # Explanation request
│   │   │   ├── standup.md         # Daily standup
│   │   │   ├── weekly-report.md   # Weekly activity report
│   │   │   ├── postmortem.md      # Incident postmortem
│   │   │   ├── runbook.md         # Runbook generation
│   │   │   ├── test.md            # Test writing
│   │   │   ├── tf-plan-review.md  # Terraform plan review
│   │   │   └── init.md            # /init project context bootstrap
│   │   ├── skills/                # Agent skills (loaded on demand)
│   │   │   ├── gh-actions/        # GitHub Actions CI/CD
│   │   │   ├── gmud-checklist/    # ITIL change request checklist
│   │   │   ├── k8s-debug/         # Kubernetes debugging
│   │   │   ├── report-builder/    # .docx report generation (pandoc + style-tables.js)
│   │   │   ├── tf-workflow/       # Terraform workflow
│   │   │   ├── meeting-prep/      # PE IT Sync Up meeting prep
│   │   │   ├── user-context/      # Personal user profile
│   │   │   └── persona-sync/      # Sync Ferri-chan persona
│   │   └── themes/
│   │       └── gruvbox.json       # Custom gruvbox pi theme
│   └── .local/bin/
│       ├── pi                     # Container launcher (podman run)
│       ├── pi-build               # Container image builder
│       └── pi-update              # Rebuild image to latest pi version
├── scripts/
│   └── .local/bin/
│       └── ollama-webui           # Launch Open WebUI + Ollama via Podman
├── task/
│   └── .config/task/
│       ├── gruvbox.theme          # Taskwarrior gruvbox colour theme
│       └── taskrc                 # Taskwarrior config + GTD reports
├── tmux/
│   └── .tmux.conf
├── .pi/
│   └── AGENTS.md                  # Project-local pi context (this file)
├── .gitignore
└── README.md
```

---

## Development Workflow

### Applying dotfiles (new machine or after changes)

```bash
# Symlink all packages
stow --restow --target="$HOME" bash kitty mise nvim pi task tmux

# Install all runtimes and LSP servers
mise install
```

### Stow a single package

```bash
cd ~/dotfiles
stow --restow --target="$HOME" nvim   # re-link after a rename/move
stow --delete --target="$HOME" nvim   # remove symlinks
```

### Key rule: **never edit files in `$HOME` directly** — always edit the source in `~/dotfiles/`.

### Running pi

```bash
# From any project directory:
pi                    # launches the Podman container, mounts cwd

# Rebuild the container image (after base changes or pi version updates):
pi-build              # builds pi-agent:latest
pi-build 0.79.10      # pin a specific version
```

### Checking for toolchain updates

```bash
mise outdated         # see what's behind
mise upgrade          # upgrade all tools
```

---

## IaC & Infrastructure

This repo contains **no IaC**. Terraform, Kubernetes, Helm, and GitHub Actions
skills/prompts exist in the pi config for use in *other* repos. The agent
should not look for `.tf` files or `k8s/` dirs here.

---

## CI/CD

No CI/CD pipeline in this repo. Changes are applied manually via `stow`.
Commits follow conventional commit format (enforced by the `commit.md` prompt).

---

## Conventions & Style

- **Stow packages:** each top-level dir = one stow package. Mirror the `$HOME`
  path structure exactly inside the package (e.g. `nvim/.config/nvim/init.lua`
  → `~/.config/nvim/init.lua`).
- **Commits:** conventional commits — `type(scope): summary` + bullet body.
  Use the `/commit` prompt template for consistency.
- **Branch strategy:** single `main` branch; all changes pushed directly.
- **Lua style:** 2-space indent, single quotes, no semicolons (match existing).
- **Bash style:** `set -euo pipefail` in all scripts, `snake_case` vars,
  UPPER_CASE for env/config vars.
- **TypeScript (pi extensions):** ESM style as used by the pi extension API;
  match surrounding code conventions.
- **No lock file edits** without being explicitly asked.
- **No placeholder files** — if adding a directory, add a real file or leave it
  absent.

---

## Hard Constraints

- **Never edit files under `$HOME` directly** — the source of truth is always
  `~/dotfiles/<package>/...`.
- **Do not add CI, Dockerfiles, or build systems** — this is a config-only repo.
- **`pi/.config/pi/auth.json` is gitignored** — never touch or expose it.
- **`pi/.config/pi/sessions/` is gitignored** — never commit session logs.
- **`*.lock` files** — do not modify `nvim-pack-lock.json` or
  `npm/package-lock.json` without explicit instruction.
- **Stow-generated symlinks in `$HOME`** — never touch them; run `stow -R` to
  recreate after edits.

---

## Key Files

| Area | File | Read before… |
|---|---|---|
| Shell | `bash/.bashrc`, `bash/.bash_aliases` | editing shell config or aliases |
| Neovim entry | `nvim/.config/nvim/init.lua` | any nvim change |
| Neovim LSP | `nvim/.config/nvim/lua/plugins/lsp.lua` | adding/removing LSP servers |
| Neovim keys | `nvim/.config/nvim/lua/keymaps.lua` | adding keybindings |
| Toolchain | `mise/.config/mise/config.toml` | adding tools or runtimes |
| pi settings | `pi/.config/pi/settings.json` | changing agent behaviour |
| pi persona | `pi/.config/pi/APPEND_SYSTEM.md` | touching the Ferri-chan persona |
| pi agent rules | `pi/.config/pi/AGENTS.md` | changing global agent instructions |
| pi container launcher | `pi/.local/bin/pi` | modifying container mounts or env |
| pi container build | `pi/.local/bin/pi-build` | modifying the image or adding deps |
| report-builder skill | `pi/.config/pi/skills/report-builder/SKILL.md` | touching report generation |
| report style script | `pi/.config/pi/skills/report-builder/scripts/style-tables.js` | modifying table styling |
