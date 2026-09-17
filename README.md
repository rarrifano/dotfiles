# dotfiles

Personal configuration files, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- GNU Stow and GNU Make
- Git, Neovim, and Bash
- GNOME with Ptyxis for `make gnome`
- The private key corresponding to the configured Git signing key

## Usage

```sh
make stow    # symlink all packages into $HOME
make unstow  # remove the symlinks
make restow  # restow all packages
make gnome   # apply GNOME/Ptyxis settings
```
