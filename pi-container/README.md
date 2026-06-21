# pi-container

Runs the `pi` CLI inside a Podman container with clipboard image support and a mounted devops context.

## Build

```sh
podman build -t pi-agent:latest -f pi-container/Containerfile .
```

To pin a different pi version:

```sh
podman build --build-arg PI_VERSION=0.79.9 -t pi-agent:latest -f pi-container/Containerfile .
```

## Usage

```sh
# From any project directory
./dotfiles/pi-container/pi-run

# Pass flags straight through to pi
./dotfiles/pi-container/pi-run -p "summarise this repo"
```

Or symlink it somewhere on your `$PATH`:

```sh
ln -s ~/dotfiles/pi-container/pi-run ~/.local/bin/pi-container
```

## Environment overrides

| Variable | Default | Description |
|---|---|---|
| `PI_IMAGE` | `pi-agent:latest` | Image to run |
| `PI_AGENT_DIR` | `~/.config/pi` | Agent config dir (auth, skills, sessions, settings, etc.) |
| `PI_WORKDIR` | `$PWD` | Host directory mounted as `/workspace` |

## Clipboard / image paste

The script auto-detects your host display session:

- **Wayland** — `WAYLAND_DISPLAY` is set → mounts `$XDG_RUNTIME_DIR/<socket>`, installs `wl-clipboard` inside the image
- **X11** — `DISPLAY` is set → mounts `/tmp/.X11-unix`, installs `xclip` inside the image

Both can be active at the same time (XWayland setups). If neither is detected, `Ctrl+V` image paste is silently unavailable and pi continues to work normally.

## Mounts summary

| Host path | Container path | Mode |
|---|---|---|
| `~/.pi/agent/` | `/root/.pi/agent/` | `rw` (settings, sessions, auth all persist to host) |
| `$PWD` | `/workspace` | `rw` |
| `/tmp/.X11-unix` | `/tmp/.X11-unix` | `ro` (X11 only) |
| `$WAYLAND_DISPLAY` socket | `/tmp/xdg-runtime/<socket>` | `ro` (Wayland only) |
