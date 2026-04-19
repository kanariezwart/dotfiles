#!/bin/zsh
# macOS system defaults
# Run this script after a fresh install to configure macOS settings
# Some settings require a logout/restart to take effect

echo "Configuring macOS settings..."

# =============================================================================
# Keyboard
# =============================================================================

# Key repeat rate (lower = faster, min 1)
defaults write NSGlobalDomain KeyRepeat -int 2

# Delay before key repeat starts (lower = sooner)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable press-and-hold for keys (enables key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# =============================================================================
# Text
# =============================================================================

# Disable automatic spelling correction
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# =============================================================================
# Dock
# =============================================================================

# Auto-hide dock
defaults write com.apple.dock autohide -bool true

# Dock size
defaults write com.apple.dock tilesize -int 43

# Dock position
defaults write com.apple.dock orientation -string "bottom"

# Remove all default app icons from dock
defaults write com.apple.dock persistent-apps -array

# Speed up dock show/hide animation
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

# =============================================================================
# Finder
# =============================================================================

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# =============================================================================
# Screensaver
# =============================================================================

# Require password after screensaver
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0

# =============================================================================
# Screenshots
# =============================================================================

# Save screenshots to Downloads
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadow
defaults write com.apple.screencapture disable-shadow -bool true

# =============================================================================
# Restart affected apps
# =============================================================================
echo "Restarting affected apps..."
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "$app" &>/dev/null
done

echo "Done! Some settings may require a logout or restart to take effect."
