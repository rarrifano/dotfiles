# dotfiles

Personal configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```sh
make stow    # symlink all packages into $HOME
make unstow  # remove the symlinks
make restow  # restow all packages
make fmt     # strip trailing whitespace
make lint    # check for trailing whitespace and stow layout
```
