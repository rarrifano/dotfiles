# dotfiles

Personal configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

- `bash`
- `git`
- `kitty`
- `pi`
- `tmux`
- `vim`

## Usage

```sh
make stow    # symlink all packages into $HOME
make unstow  # remove the symlinks
make lint    # strip trailing whitespace and check formatting
```
