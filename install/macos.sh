#!/bin/zsh
# macOS system defaults
# Records the settings of the current Mac; settings left at the macOS default
# are not listed. Run this script after a fresh install to configure macOS.
# Some settings require a logout/restart to take effect

echo "Configuring macOS settings..."

# =============================================================================
# Keyboard
# =============================================================================

# Key repeat rate (lower = faster, min 1)
defaults write NSGlobalDomain KeyRepeat -int 2

# Delay before key repeat starts (lower = sooner)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# =============================================================================
# Text
# =============================================================================

# Automatic spelling correction
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true

# Smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true

# Smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true

# =============================================================================
# Dock
# =============================================================================

# Auto-hide dock
defaults write com.apple.dock autohide -bool true

# Dock size
defaults write com.apple.dock tilesize -int 43

# Dock position
defaults write com.apple.dock orientation -string "bottom"

# =============================================================================
# Finder
# =============================================================================

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Default to column view
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Screenshot location (~/Documents/Screenshots) is set by `make screenshots`

# =============================================================================
# Restart affected apps
# =============================================================================
echo "Restarting affected apps..."
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "$app" &>/dev/null
done

echo "Done! Some settings may require a logout or restart to take effect."
