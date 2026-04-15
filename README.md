# dotfiles

Personal dotfiles for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── git/        # .gitconfig, .gitconfig.local, .gitignore_global
├── shell/      # .shell_env
├── zsh/        # .zshrc, .zsh/aliases.zsh, .zsh/functions.zsh
├── install/    # Brewfile, Caskfile
├── install.sh  # bootstrap script for new machines
└── Makefile    # stow / unstow / update
```

## Fresh install

On a new Mac, run:

```zsh
curl -fsSL https://raw.githubusercontent.com/kanariezwart/dotfiles/main/install.sh | zsh
```

This will:
1. Install Homebrew if not present
2. Clone this repo to `~/Projects/system/dotfiles`
3. Install all packages from `install/Brewfile`
4. Symlink all dotfiles to `~` via Stow

## Manual install

```zsh
git clone git@github.com:kanariezwart/dotfiles.git ~/Projects/system/dotfiles
cd ~/Projects/system/dotfiles
make install
```

## Commands

| Command | Description |
|---|---|
| `make install` | Install brew packages and create all symlinks |
| `make stow` | Create symlinks only |
| `make unstow` | Remove all symlinks |
| `make update` | Pull latest changes and restow |

## Adding a new dotfile

1. Create a new package directory (e.g. `nano/`)
2. Mirror the home directory structure inside it (e.g. `nano/.nanorc`)
3. Add the package name to `PACKAGES` in the Makefile and `install.sh`
4. Run `make stow`

## Plugins

Zsh plugins are managed by [zcomet](https://github.com/agkozak/zcomet).
To update all plugins:

```zsh
update_zcomet
```

## Requirements

- macOS
- Zsh
- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)
