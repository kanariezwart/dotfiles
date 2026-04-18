# dotfiles

Personal dotfiles for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── git/        # .gitconfig, .gitconfig.local, .gitignore_global
├── shell/      # .shell_env
├── zsh/        # .zshrc, .zsh/aliases.zsh, .zsh/functions.zsh, .p10k.zsh
├── install/
│   ├── Brewfile      # base packages and apps
│   └── Brewfile.dev  # development tools
├── install.sh  # bootstrap script for new machines
└── Makefile
```

## Fresh install

On a new Mac, run:

```zsh
curl -fsSL https://raw.githubusercontent.com/kanariezwart/dotfiles/main/install.sh | zsh
```

Or with a custom dotfiles path:

```zsh
curl -fsSL https://raw.githubusercontent.com/kanariezwart/dotfiles/main/install.sh | zsh -s ~/path/to/dotfiles
```

This will:
1. Check for Homebrew and install if not present
2. Check for Stow and install if not present
3. Clone this repo to `~/Projects/system/dotfiles` (or custom path)
4. Install all packages from `install/Brewfile`
5. Symlink all dotfiles to `~` via Stow

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
| `make brew` | Install base packages from Brewfile only |
| `make dev` | Install development tools from Brewfile.dev |
| `make stow` | Create symlinks only |
| `make unstow` | Remove all symlinks |
| `make update` | Pull latest changes and restow |

## Stow packages

Each directory is a Stow package that mirrors the home directory structure:

| Package | Symlinks to |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.zsh/`, `~/.p10k.zsh` |
| `git/` | `~/.gitconfig`, `~/.gitignore_global` |
| `shell/` | `~/.shell_env` |

## Sensitive data

Personal settings like email, signing key and tokens go in `~/.gitconfig.local` — this file is excluded from the repo via `.gitignore`.

Template:

```ini
[user]
  email = your@email.com
  signingkey = YOUR_GPG_KEY

[github]
  user = your-username
```

## Environment variable

The `DOTFILES` variable points to the repo location and is set in `~/.shell_env`:

```zsh
export DOTFILES="$HOME/Projects/system/dotfiles"
```

Override by passing a path to `install.sh` or by editing `.shell_env` after installation.

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
