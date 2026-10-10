# dotfiles

Personal dotfiles for macOS (and Debian/Ubuntu), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── git/            # .gitconfig, .gitconfig.local, .gitignore_global
├── shell/          # .shell_env
├── zsh/            # .zprofile, .zshrc, .zsh/aliases.zsh, .zsh/functions.zsh, .p10k.zsh
├── iterm2/         # iTerm2 configuration
├── install/
│   ├── Brewfile          # base packages and apps
│   ├── Brewfile.dev      # development tools
│   ├── apt.txt           # Linux (Debian/Ubuntu) packages
│   └── macos.sh          # macOS system defaults
├── install.sh      # bootstrap script for new machines
├── test/           # Docker test environment (vanilla Ubuntu)
└── Makefile
```

## Fresh install (macOS)

### Before you start

- **Sign in to the App Store.** Some apps (Bitwarden) are installed from the
  Mac App Store via `mas`, which can't sign in for you.
- Expect it to take a while: Homebrew, the Xcode Command Line Tools and all
  apps are downloaded. On an Intel Mac, Homebrew no longer ships prebuilt
  packages, so some formulae are compiled from source.

### Run the bootstrap

```zsh
curl -fsSL https://raw.githubusercontent.com/kanariezwart/dotfiles/main/install.sh | zsh
```

Or with a custom dotfiles path:

```zsh
curl -fsSL https://raw.githubusercontent.com/kanariezwart/dotfiles/main/install.sh | zsh -s ~/path/to/dotfiles
```

This will:
1. Install Homebrew and Stow if they are missing
2. Clone this repo to `~/Projects/system/dotfiles` (or the custom path) over HTTPS
3. Install all packages and apps from `install/Brewfile`. If single entries
   fail (e.g. not signed in to the App Store), it warns and continues;
   rerun `make brew` afterwards
4. Symlink the dotfiles into `~` via Stow
5. Run the one-time setup (`make setup`): Screenshots folder, SSH folder with
   a `~/.ssh/config.local` template included from `~/.ssh/config`, macOS
   defaults and the iTerm2 configuration

### After the bootstrap

1. **Restart iTerm2** (quit with ⌘Q) so it loads the imported profile and the
   MesloLGS NF font, then open a new window: you should see the
   Powerlevel10k prompt.
2. **Create `~/.gitconfig.local`** with your email and signing key (see
   [Machine-local files](#machine-local-files)). Commits are GPG-signed by
   default, so this is needed before your first commit.
3. **Set up SSH:** add your key to `~/.ssh` and GitHub, put your hosts in
   `~/.ssh/config.local`, then switch the repo to SSH if you like:
   `git -C ~/Projects/system/dotfiles remote set-url origin git@github.com:kanariezwart/dotfiles.git`
4. **Development machine?** Third-party taps must be trusted first
   (Homebrew 7), then install the dev tools:
   ```zsh
   brew trust oven-sh/bun
   make dev
   ```
5. **Check the result:** `make brew-check` should only list things you
   installed deliberately outside the Brewfiles.

Some macOS defaults only take effect after logging out and in again.

## Fresh install (Debian/Ubuntu)

`install.sh` and `make install` are macOS-only (Homebrew, `defaults`). On
Debian/Ubuntu:

```zsh
sudo apt-get update && sudo apt-get install -y git make stow zsh
git clone https://github.com/kanariezwart/dotfiles.git ~/Projects/system/dotfiles
cd ~/Projects/system/dotfiles
make stow                 # symlink the dotfiles (move conflicting files like ~/.zshrc aside first)
make linux                # tools from install/apt.txt (dig, curl, fzf)
make ssh                  # SSH folder, ~/.ssh/config.local included from ~/.ssh/config
chsh -s "$(command -v zsh)"
```

Then log out and in again. On minimal installs (servers, containers), also
generate the locale that `.shell_env` sets, or the prompt symbols break:
`sudo apt-get install -y locales && sudo locale-gen en_US.UTF-8`.

The first zsh start clones zcomet and the plugins (~20s). `make docker-test`
runs the same `make stow` + `make linux` steps in a clean Ubuntu container.

## Manual install (macOS)

```zsh
git clone git@github.com:kanariezwart/dotfiles.git ~/Projects/system/dotfiles
cd ~/Projects/system/dotfiles
make install
```

## Keeping up to date

| Command | What it does |
|---|---|
| `update` | macOS software updates, Homebrew (formulae and casks) and zsh plugins |
| `make update` | Pull the latest dotfiles and restow |
| `make brew-check` | Show drift between installed Homebrew packages and the Brewfiles |
| `update_zcomet` | Update zsh plugins only |

## Commands

| Command | Description |
|---|---|
| `make install` | Full install: brew packages, symlinks and one-time setup |
| `make brew` | Install base packages from Brewfile |
| `make brew-check` | Show drift between installed Homebrew packages and the Brewfiles |
| `make dev` | Install development tools from `Brewfile.dev` |
| `make linux` | Install Linux packages from `install/apt.txt` (Debian/Ubuntu) |
| `make stow` | Create symlinks only |
| `make unstow` | Remove all symlinks |
| `make test` | Simulate stow without modifying filesystem |
| `make docker-test` | Smoke test zsh startup in a vanilla Linux container |
| `make docker-shell` | Open zsh with these dotfiles in a vanilla Linux container |
| `make update` | Pull latest changes and restow |
| `make setup` | Run all one-time setup tasks |
| `make defaults` | Apply macOS system defaults |
| `make iterm` | Import iTerm2 configuration |
| `make ssh` | Create SSH directory and a config.local template, included from ~/.ssh/config |
| `make screenshots` | Create Screenshots directory |

## Stow packages

Each directory is a Stow package that mirrors the home directory structure:

| Package | Symlinks to |
|---|---|
| `zsh/` | `~/.zprofile`, `~/.zshrc`, `~/.zsh/`, `~/.p10k.zsh` |
| `git/` | `~/.gitconfig`, `~/.gitignore_global` |
| `shell/` | `~/.shell_env` |

## Machine-local files

Settings that differ per machine or contain secrets live in `*.local` files.
They are not committed (`.gitignore`), and each is loaded only if it exists:

| File | Loaded by | For |
|---|---|---|
| `~/.gitconfig.local` | `~/.gitconfig` | email, signing key, GitHub user |
| `~/.zshrc.local` | `~/.zshrc` | machine-specific aliases, functions and plugins |
| `~/.ssh/config.local` | `~/.ssh/config` (`make ssh` adds the `Include`) | SSH host definitions |

`~/.gitconfig.local` template:

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

## Testing in a vanilla Linux container

Requires Docker. The repo is mounted read-only and copied into a fresh
`ubuntu:24.04` container on every run, so uncommitted changes are picked up
without rebuilding. Gitignored files (`*.local` secrets) are not copied.

```zsh
make docker-test   # stow + `make linux` + start a login shell; fails on any
                   # startup output or a broken function
make docker-shell  # same setup, but drops you into an interactive zsh
```

Each run starts from scratch, so it takes ~30s before the prompt appears
(installing packages, cloning zcomet and its plugins); progress is printed
along the way.

In `make docker-shell`, try for example:

```zsh
calc 22/7            # functions
escape €
ip example.com
digga example.com
alias                # aliases
git <Tab>            # completion (fzf-tab)
echo $DOTFILES       # environment from .zprofile / .shell_env
exit                 # leave; the container is removed
```

## Plugins

Zsh plugins are managed by [zcomet](https://github.com/agkozak/zcomet).
To update all plugins:

```zsh
update_zcomet
```

## Requirements

- macOS (Apple Silicon or Intel) with [Homebrew](https://brew.sh), or
  Debian/Ubuntu with `apt`
- Zsh 5.x
- [GNU Stow](https://www.gnu.org/software/stow/) and `make`
  (installed by the bootstrap / the apt step above)
