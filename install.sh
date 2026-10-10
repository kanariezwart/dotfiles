#!/bin/zsh

set -e

DOTFILES="${1:-$HOME/Projects/system/dotfiles}"

# Check if zsh is the default shell
[ "${SHELL##/*/}" != "zsh" ] && echo "You might need to change your default shell to zsh: chsh -s /bin/zsh"

# =============================================================================
# Pre-install checks
# =============================================================================

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # brew is not on PATH yet in this shell (Apple Silicon: /opt/homebrew)
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$_brew" ]] && eval "$("$_brew" shellenv)" && break
  done
else
  echo "✓ Homebrew already installed"
fi

# Install stow if not present
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  brew install stow
else
  echo "✓ Stow already installed"
fi

# =============================================================================
# Clone dotfiles
# =============================================================================
if [[ ! -d "$DOTFILES" ]]; then
  echo "Cloning dotfiles to $DOTFILES..."
  mkdir -p "$DOTFILES"
  # HTTPS: a fresh machine has no SSH key yet
  git clone https://github.com/kanariezwart/dotfiles.git "$DOTFILES"
else
  echo "✓ Dotfiles already cloned at $DOTFILES"
fi

cd "$DOTFILES"

# =============================================================================
# Install packages and symlinks
# =============================================================================
echo "Installing brew packages..."
# Don't abort the bootstrap when single entries fail (e.g. mas apps need a
# signed-in App Store account); stow and setup should still run
brew bundle --file=install/Brewfile \
  || echo "⚠ Some Brewfile entries failed – fix the cause and rerun: make brew"

echo "Creating symlinks..."
for package in zsh git shell; do
  stow --target="$HOME" "$package"
done

# zcomet is normally bootstrapped by .zshrc, but `make solarized` needs it now
if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  git clone https://github.com/agkozak/zcomet.git "${ZDOTDIR:-${HOME}}/.zcomet/bin"
fi

echo "Running one-time setup..."
make setup

echo "Done!"
