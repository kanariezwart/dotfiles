DOTFILES := $(shell pwd)
PACKAGES := zsh git shell

.PHONY: help install brew dev stow unstow update test iterm

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: brew stow ## Install brew packages and create all symlinks

brew: ## Install base packages from Brewfile
	brew bundle --file=install/Brewfile

dev: ## Install development tools from Brewfile.dev
	brew bundle --file=install/Brewfile.dev

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

update: ## Pull latest changes and restow
	git pull
	$(MAKE) stow

test: ## Simulate stow without modifying filesystem
	@echo "Simulating stow..."
	@for package in $(PACKAGES); do \
		echo "Testing $$package..."; \
		stow --simulate --target=$(HOME) $$package; \
	done
	@echo "All packages OK!"

iterm: ## Import iTerm2 configuration
	defaults import com.googlecode.iterm2 $(DOTFILES)/iterm2/com.googlecode.iterm2.plist
