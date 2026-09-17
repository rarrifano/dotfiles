# dotfiles

Personal configuration files, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```sh
make stow    # symlink all packages into $HOME
make unstow  # remove the symlinks
make restow  # restow all packages
make gnome   # apply GNOME/Ptyxis settings
make fmt     # check files for 80-column lines
```
