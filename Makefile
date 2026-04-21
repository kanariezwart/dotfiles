DOTFILES := $(shell pwd)
PACKAGES := zsh git shell

.PHONY: help install brew dev dev-go dev-php dev-ruby dev-python dev-java dev-infra dev-apps \
        stow unstow update test setup defaults iterm solarized ssh screenshots

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: brew stow setup ## Full install: brew packages, symlinks and one-time setup

# =============================================================================
# Packages
# =============================================================================
brew: ## Install base packages from Brewfile
	brew bundle --file=install/Brewfile

dev: dev-go dev-php dev-ruby dev-python dev-java dev-infra dev-apps ## Install all development tools

dev-go: ## Install Go tools
	brew bundle --file=install/Brewfile.go

dev-php: ## Install PHP tools
	brew bundle --file=install/Brewfile.php

dev-ruby: ## Install Ruby tools
	brew bundle --file=install/Brewfile.ruby

dev-python: ## Install Python tools
	brew bundle --file=install/Brewfile.python

dev-java: ## Install Java tools
	brew bundle --file=install/Brewfile.java

dev-infra: ## Install infrastructure tools
	brew bundle --file=install/Brewfile.infra

dev-apps: ## Install development apps
	brew bundle --file=install/Brewfile.apps.dev

# =============================================================================
# Stow
# =============================================================================
stow: ## Create symlinks via stow
	@for package in $(PACKAGES); do \
		echo "Stowing $$package..."; \
		stow --target=$(HOME) $$package; \
	done

unstow: ## Remove all symlinks
	@for package in $(PACKAGES); do \
		echo "Unstowing $$package..."; \
		stow --delete --target=$(HOME) $$package; \
	done

test: ## Simulate stow without modifying filesystem
	@echo "Simulating stow..."
	@for package in $(PACKAGES); do \
		echo "Testing $$package..."; \
		stow --simulate --target=$(HOME) $$package; \
	done
	@echo "All packages OK!"

# =============================================================================
# Maintenance
# =============================================================================
update: ## Pull latest changes and restow
	git pull
	$(MAKE) stow

# =============================================================================
# One-time setup
# =============================================================================
setup: screenshots ssh solarized defaults iterm ## Run all one-time setup tasks

screenshots: ## Create Screenshots directory
	@echo "Creating Screenshots directory..."
	@mkdir -p $(HOME)/Screenshots
	@defaults write com.apple.screencapture location -string "$(HOME)/Screenshots"
	@echo "✓ Screenshots -> ~/Screenshots"

ssh: ## Create SSH directory and config.local template
	@echo "Setting up SSH..."
	@mkdir -p $(HOME)/.ssh && chmod 700 $(HOME)/.ssh
	@if [[ ! -f "$(HOME)/.ssh/config.local" ]]; then \
		printf "# Local SSH host definitions\n# Add your hosts here\n\n# Example:\n# Host myserver\n#   HostName 1.2.3.4\n#   User myuser\n#   Port 22\n#   IdentityFile ~/.ssh/id_ed25519\n" \
			> $(HOME)/.ssh/config.local; \
		echo "✓ Created ~/.ssh/config.local template"; \
	else \
		echo "✓ ~/.ssh/config.local already exists"; \
	fi

solarized: ## Setup solarized dircolors
	@echo "Setting up solarized dircolors..."
	@if [[ ! -f "$(HOME)/.zsh-dircolors.config" ]]; then \
		zsh -c 'source $${ZDOTDIR:-$$HOME}/.zcomet/bin/zcomet.zsh && \
			zcomet load joel-porquet/zsh-dircolors-solarized && \
			setupsolarized dircolors.ansi-dark'; \
		echo "✓ Solarized dircolors configured"; \
	else \
		echo "✓ Solarized dircolors already configured"; \
	fi

defaults: ## Apply macOS system defaults (macOS only)
	@[[ "$$(uname)" == "Darwin" ]] \
		&& bash install/macos.sh \
		|| echo "⚠ Skipping macOS defaults on non-macOS system"

iterm: ## Import iTerm2 configuration (macOS only)
	@echo "Importing iTerm2 configuration..."
	@if [[ -f "$(DOTFILES)/iterm2/com.googlecode.iterm2.plist" ]]; then \
		defaults import com.googlecode.iterm2 $(DOTFILES)/iterm2/com.googlecode.iterm2.plist; \
		echo "✓ iTerm2 configuration imported"; \
	else \
		echo "⚠ No iTerm2 configuration found, skipping"; \
	fi
