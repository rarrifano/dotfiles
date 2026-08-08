# Dotfiles Agent Instructions

## Repo Layout

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package symlinked into `$HOME`:

```
bash/   → ~/.bashrc
kitty/  → ~/.config/kitty/
mise/   → ~/.config/mise/
nvim/   → ~/.config/nvim/
pi/     → ~/.config/pi/, ~/.local/bin/pi*
```

Deploy with `./stow.sh` (`stow --no-folding -t $HOME`).

All config files in this repo are symlinked into `$HOME` via stow. Editing files here edits them live (the symlink already resolves to this repo). Never copy or duplicate config files outside the repo — always edit the source here.

## Key Constraints

- **Never touch** `pi/.config/pi/auth.json`, `*/sessions/`, `*/npm/`, `models-store.json`, or `trust.json` — all gitignored for good reason.
- `pi/.stow-local-ignore` controls what stow skips; edit it when adding files that should not be symlinked.
- `.pre-commit-config.yaml` enforces trailing-whitespace, EOF newlines, valid YAML/TOML/JSON, shellcheck on bash files, and StyLua on Lua files. Run `pre-commit run --all-files` before committing.

## Per-Package Notes

**bash** — single `.bashrc`; shellcheck runs on commit (severity: warning).

**nvim** — Lua config under `lua/`. StyLua is enforced via `stylua.toml`. Plugin lock file is `nvim-pack-lock.json` — don't hand-edit it.

**pi** — "pi container" refers to `pi/.local/bin/`. Extensions live in `extensions/`. `settings.json` is the source of truth for active extensions (the `extensions` array). `hide-cursor.ts` is loaded as an extension alongside `rewind-footer.ts`. `AGENTS.md` and `APPEND_SYSTEM.md` are the global agent config files; edit them here, not directly in `~/.config/pi/`.

**kitty** — `pass_keys.py` is a helper script for Kitty keyboard pass-through; keep it alongside `kitty.conf`.

## Workflow

- Changes here are not live until `stow.sh` is re-run (or the symlink already exists).
- Config changes to pi take effect on the next pi session start.
- Don't add new stow packages without updating `stow.sh`.
