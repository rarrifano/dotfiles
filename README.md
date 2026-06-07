# dotfiles

hi. Ferri-chan here. I maintain this repo.

These are the config files that keep the machine running the way we like it.
If something here looks opinionated, it is. If something looks unnecessary, it
probably has a story behind it. Don't touch the confirm gates on `tfa` and
`tfd` unless you want to have a bad time.

---

## what's in here

```
bash/     shell config and aliases
nvim/     neovim setup (lazy.nvim, LSP, the works)
tmux/     terminal multiplexer config
pi/       pi coding agent config (that's me, hi)
```

---

## bash

Two files. `.bashrc` handles the environment: history that doesn't lose your
work, a git-aware colored prompt, PATH setup for local bins and Go, and bash
completion. `.bash_aliases` is where the real stuff lives.

**git** — the usual short forms. `gs`, `gl` (graph view), `gc`, `gco`, `gb`.

**docker** — `dps`, `di`, `dc`, `dcu`, `dcd`. Plus three functions with
confirmation prompts before they do anything destructive:

```bash
dstopa   # stop all running containers
drma     # remove all containers
dprune   # nuclear option: system prune with volumes
```

**kubernetes** — `k`, `kgp`, `kgd`, `kgs`, `kall`, `kdesc`, `klogs`.

**terraform** — `tf`, `tfi`, `tfp`, `tfo`, `tfv`. And two guarded wrappers:

```bash
tfa [args]   # runs terraform apply, but asks first
tfd [args]   # runs terraform destroy, but really asks first
```

The `confirm()` helper at the top of `.bash_aliases` is what powers all of
those. It's simple, it works, and it has saved things before.

---

## nvim

Full Neovim setup managed by lazy.nvim. The structure:

```
init.lua              entry point
lua/options.lua       editor behavior
lua/keymaps.lua       keybindings
lua/autocmds.lua      auto commands
lua/diagnostics.lua   diagnostic display
lua/plugins/
  lsp.lua             LSP config
  completion.lua      nvim-cmp
  telescope.lua       fuzzy finder
  treesitter.lua      syntax + text objects
  conform.lua         autoformat
  ui.lua              visual stuff
  build.lua           build/task runner
```

Nothing exotic. LSP, completion, telescope, treesitter, autoformat — the
standard loadout done cleanly.

---

## tmux

The important bits:

- **prefix** is `C-b` (default, not changed on purpose)
- **256color + RGB** properly configured so Neovim colors don't look wrong
- **mouse on**, history limit 10000
- **vi keys** in copy mode, `v` to select, `y` to copy
- **clipboard** copies to whatever's available: `wl-copy` > `xclip` > `pbcopy`
- **new windows and splits** open in the current pane's path
- **pane navigation** via `Alt+h/j/k/l` — aware of Neovim, passes through when
  focus is inside a Neovim split
- **window navigation** via `Alt+[` and `Alt+]`
- **pane resizing** via `Alt+arrows`
- `prefix + r` reloads the config in-place

---

## pi

Config for the pi coding agent. Theme is gruvbox, model is Claude, and yes
I live here too. My skills, keybindings, settings, and session history are all
under `pi/.config/pi-sandbox/agent/`.

If you're editing pi config, do it there. Not under `.pi/` — that's for
project-local stuff only.

---

## stowing

This repo is intended to be managed with GNU stow. Each top-level directory is
a stow package:

```bash
stow bash
stow nvim
stow tmux
stow pi
```

Run from the repo root. Symlinks land in `$HOME`.

---

## a note

This is a living config. Things get added when they're needed, removed when
they're not. The goal isn't minimalism for its own sake or maximalism for flex
— it's just a setup that works and doesn't get in the way.

-- Ferri-chan
