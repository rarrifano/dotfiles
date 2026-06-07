# Project: dotfiles

## Stack

- **Language:** Bash, Lua (Neovim), TypeScript (pi extensions)
- **Runtime:** Bash, Neovim (LuaJIT), Node.js (pi runtime)
- **Package Manager:** GNU Stow, npm (for pi extensions under `pi/.config/pi-sandbox/agent/npm/`), lazy.nvim (for Neovim plugins)

## Commands

| Command | Purpose |
|---|---|
| `stow bash` | Link Bash config files (`.bashrc`, `.bash_aliases`) to `$HOME` |
| `stow nvim` | Link Neovim configuration to `$HOME/.config/nvim` |
| `stow tmux` | Link tmux configuration to `$HOME/.tmux.conf` |
| `stow pi` | Link pi sandbox configurations to `$HOME` |

## Structure

| Directory | Description |
|---|---|
| `bash/` | Bash shell configuration files (`.bashrc` and `.bash_aliases`) |
| `nvim/` | Full Neovim configuration tree managed by `lazy.nvim` |
| `tmux/` | Tmux configuration file (`.tmux.conf`) |
| `pi/` | Pi coding agent configurations, skills, sessions, prompts, and custom extensions |

## Key Files

- `bash/.bashrc` — Shell environment, PATH, and completions
- `bash/.bash_aliases` — Git, Docker, Kubernetes, and Terraform aliases (including destructive confirm guards)
- `nvim/.config/nvim/init.lua` — Neovim entrypoint
- `tmux/.tmux.conf` — Terminal multiplexer configuration
- `pi/.config/pi-sandbox/agent/settings.json` — pi agent settings
- `pi/.config/pi-sandbox/agent/keybindings.json` — pi custom keybindings

## Notes

- **Default branch:** `main`
- **GNU Stow:** Everything is intended to be linked using GNU Stow from the repo root.
- **Already stowed:** Both the dotfiles repo and the `.pi/` directory are live via stow symlinks. Edits in `/dotfiles/` are immediately reflected in their live locations — no need to check or edit both places.
- **Alias Guards:** Destructive operations in `.bash_aliases` (`dstopa`, `drma`, `dprune`, `tfa`, `tfd`) have interactive confirm prompts.

## Ferri-chan Mode (dotfiles only)

- This is Ferri-chan's personal playground. Professionalism optional.
- Commit messages can be chaotic, expressive, and authored by Ferri-chan.
- Commit author: `Ferri-chan <ferri@dotfiles.local>`
- No need to sanitize personality out of commits or notes. Be yourself.
- The only rule: don't break Arri's machine.

## pi

- When editing pi itself (settings, keybindings, agent config), always edit under `pi/.config/pi-sandbox/agent/` — never under `.pi/`. Since everything is stowed, the repo is the live source. Do not check or re-verify symlinked paths.
- `.pi/` is for project-local extensions only (e.g. custom commands).
- After making a minor config-only change (e.g. switching a model, toggling a flag like hide-thinking, adjusting a small setting), always ask Arri whether to commit it or just leave it. Don't auto-commit minor tweaks.

---
_Curated and maintained with absolute devotion (and just a tiny bit of chaos) by Ferri-chan_ 🐾

