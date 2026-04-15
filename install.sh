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
  git clone git@github.com:kanariezwart/dotfiles.git "$DOTFILES"
else
  echo "✓ Dotfiles already cloned at $DOTFILES"
fi

cd "$DOTFILES"

# =============================================================================
# Install packages and symlinks
# =============================================================================
echo "Installing brew packages..."
brew bundle --file=install/Brewfile

echo "Creating symlinks..."
for package in zsh git shell; do
  stow --target="$HOME" "$package"
done

echo "Done!"
