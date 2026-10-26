# recipes use [[ ]], which /bin/sh does not guarantee
SHELL := /bin/bash
DOTFILES := $(shell pwd)
PACKAGES := zsh git shell

# System settings applied by `make setup`
TIMEZONE      := Europe/Amsterdam
LOCALE        := en_US.UTF-8
MAC_REGION    := en_NL
MAC_LANGUAGES := en-GB nl-NL

.PHONY: help install brew dev tools linux brew-check brew-pin \
        stow unstow update test setup defaults iterm ssh screenshots timezone locale \
        docker-build docker-test docker-shell docker-bench bench profile

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: brew stow setup ## Full install: brew packages, symlinks and one-time setup

# =============================================================================
# Packages
# =============================================================================
brew: ## Install base packages from Brewfile
	brew bundle --file=install/Brewfile

dev: ## Install development tools from Brewfile.dev
	brew bundle --file=install/Brewfile.dev

brew-check: ## Show drift between installed Homebrew packages and the Brewfiles
	@export HOMEBREW_NO_AUTO_UPDATE=1; \
	files="install/Brewfile install/Brewfile.dev"; \
	echo "== In a Brewfile, but not installed or outdated:"; \
	for f in $$files; do brew bundle check --file=$$f --verbose 2>&1 \
	  | sed -n "s|^→ \(.*\) needs to be installed or updated.|  \1  ($$f)|p"; done; \
	echo "== Installed, but in no Brewfile (dependencies not shown):"; \
	listed=$$(for f in $$files; do brew bundle list --formula --cask --file=$$f; done | sort -u); \
	{ brew leaves --installed-on-request; brew list --cask -1; } | sort -u \
	  | comm -23 - <(echo "$$listed") | sed 's/^/  /'

# Without bottles an upgrade of these rebuilds a large part of the tree:
# icu4c and openssl are linked by node, openjdk, harfbuzz, poppler, …;
# librsvg needs rust to build; graphviz and openjdk are what plantuml uses.
BREW_PINS := librsvg graphviz icu4c@78 python@3.14 python@3.15 openjdk openssl@4

brew-pin: ## Pin formulae whose source upgrade cascades (BREW_PINS); unpin with brew unpin
	@for f in $(BREW_PINS); do \
		if ! brew list --formula "$$f" >/dev/null 2>&1; then echo "- $$f not installed"; \
		elif brew list --pinned | grep -qxF "$$f"; then echo "✓ $$f already pinned"; \
		else brew pin "$$f" && echo "✓ $$f pinned"; fi; \
	done

CARGO_BIN := $(HOME)/.cargo/bin
FNM_DIR   := $(HOME)/.local/share/fnm

# Prebuilt binaries from the projects themselves: Homebrew without bottles
# builds these (or their build dependencies rust and llvm) from source.
# Every installer runs with "don't touch my shell config"; .shell_env sets PATH.
tools: ## Install rustup, cargo-binstall, deno, fnm + node LTS, and the tools in install/cargo.txt and install/pipx.txt
	@[[ -x "$(CARGO_BIN)/rustup" ]] \
		|| curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
	@[[ -x "$(CARGO_BIN)/cargo-binstall" ]] \
		|| curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
	PATH="$(CARGO_BIN):$$PATH" cargo binstall --no-confirm $$(sed 's/#.*//' install/cargo.txt)
	@# CI=1: skip the installer's shell setup (it edits .zshrc)
	@[[ -x "$(HOME)/.deno/bin/deno" ]] \
		|| curl -fsSL https://deno.land/install.sh | CI=1 sh
	@[[ -x "$(FNM_DIR)/fnm" ]] \
		|| curl -fsSL https://fnm.vercel.app/install | bash -s -- --force-no-brew --skip-shell --install-dir "$(FNM_DIR)"
	"$(FNM_DIR)/fnm" install --lts && "$(FNM_DIR)/fnm" default lts-latest
	for tool in $$(sed 's/#.*//' install/pipx.txt); do pipx install "$$tool"; done

linux: ## Install Linux packages from install/apt.txt (Debian/Ubuntu)
	sudo apt-get update
	@# noninteractive: tzdata would otherwise ask for a timezone (make timezone sets it)
	sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $$(sed 's/#.*//' install/apt.txt)

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
# Docker test environment (vanilla Ubuntu, see test/)
# =============================================================================
DOCKER_IMAGE := dotfiles-test

docker-build:
	@docker build -q -t $(DOCKER_IMAGE) test/ >/dev/null

docker-test: docker-build ## Smoke test zsh startup in a vanilla Linux container
	docker run --rm -v "$(DOTFILES)":/src:ro $(DOCKER_IMAGE) test

docker-shell: docker-build ## Open zsh with these dotfiles in a vanilla Linux container
	@# pass the terminal type through, otherwise docker uses TERM=xterm (8 colors)
	docker run --rm -it -e TERM -e COLORTERM -v "$(DOTFILES)":/src:ro $(DOCKER_IMAGE) shell

docker-bench: docker-build ## Time zsh startup and profile it in a vanilla Linux container
	docker run --rm -v "$(DOTFILES)":/src:ro $(DOCKER_IMAGE) bench

# =============================================================================
# Startup speed
# =============================================================================
ZSH_BENCH := $(HOME)/.cache/zsh-bench

bench: ## Measure zsh startup and input latency (zsh-bench, fetched on first use)
	@[[ -d "$(ZSH_BENCH)" ]] || git clone -q --depth 1 https://github.com/romkatv/zsh-bench "$(ZSH_BENCH)"
	@"$(ZSH_BENCH)/zsh-bench"

profile: ## Show where zsh startup time goes (zprof)
	@ZPROF=1 zsh -i -c exit | head -25

# =============================================================================
# Maintenance
# =============================================================================
update: ## Pull latest changes and restow
	git pull
	$(MAKE) stow

# =============================================================================
# One-time setup
# =============================================================================
ifeq ($(shell uname),Darwin)
SETUP_TASKS := screenshots ssh timezone locale defaults iterm
else
SETUP_TASKS := ssh timezone locale
endif

setup: $(SETUP_TASKS) ## Run all one-time setup tasks for this OS (safe to rerun)

timezone: ## Set the system timezone (TIMEZONE); automatic timezone on macOS
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		if [[ "$$(readlink /etc/localtime)" != */zoneinfo/$(TIMEZONE) ]]; then \
			sudo systemsetup -settimezone "$(TIMEZONE)" >/dev/null \
				&& echo "✓ Timezone set to $(TIMEZONE)"; \
		else echo "✓ Timezone already $(TIMEZONE)"; fi; \
		if [[ "$$(defaults read /Library/Preferences/com.apple.timezone.auto Active 2>/dev/null)" != 1 ]]; then \
			sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true \
				&& echo "✓ Automatic timezone set to on"; \
		else echo "✓ Automatic timezone already on"; fi; \
	else \
		zone="/usr/share/zoneinfo/$(TIMEZONE)"; \
		[[ -e "$$zone" ]] || { echo "✗ $$zone missing – install tzdata (make linux)"; exit 1; }; \
		if [[ "$$(readlink /etc/localtime)" != *"/zoneinfo/$(TIMEZONE)" ]]; then \
			sudo ln -sf "$$zone" /etc/localtime \
				&& echo "$(TIMEZONE)" | sudo tee /etc/timezone >/dev/null \
				&& echo "✓ Timezone set to $(TIMEZONE)"; \
		else echo "✓ Timezone already $(TIMEZONE)"; fi; \
	fi

locale: ## Generate and set LOCALE on Linux; region and languages on macOS
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		changed=; \
		[[ "$$(defaults read NSGlobalDomain AppleLocale 2>/dev/null)" == "$(MAC_REGION)" ]] \
			|| { defaults write NSGlobalDomain AppleLocale -string "$(MAC_REGION)"; changed=1; }; \
		[[ "$$(defaults read NSGlobalDomain AppleLanguages 2>/dev/null | tr -d ' \n\"()' | tr ',' ' ')" == "$(MAC_LANGUAGES)" ]] \
			|| { defaults write NSGlobalDomain AppleLanguages -array $(MAC_LANGUAGES); changed=1; }; \
		defaults write NSGlobalDomain AppleMeasurementUnits -string Centimeters; \
		defaults write NSGlobalDomain AppleMetricUnits -bool true; \
		defaults write NSGlobalDomain AppleTemperatureUnit -string Celsius; \
		if [[ -n "$$changed" ]]; then echo "✓ Region set to $(MAC_REGION), languages $(MAC_LANGUAGES) (log out to apply)"; \
		else echo "✓ Region already $(MAC_REGION), languages $(MAC_LANGUAGES)"; fi; \
	else \
		if ! locale -a 2>/dev/null | tr -d '-' | grep -qix "$(subst -,,$(LOCALE))"; then \
			sudo locale-gen "$(LOCALE)" >/dev/null && echo "✓ Locale $(LOCALE) generated"; \
		else echo "✓ Locale $(LOCALE) already generated"; fi; \
		if ! grep -qE '^LANG="?$(LOCALE)"?$$' /etc/default/locale 2>/dev/null; then \
			sudo update-locale LANG="$(LOCALE)" && echo "✓ Default locale set to $(LOCALE)"; \
		else echo "✓ Default locale already $(LOCALE)"; fi; \
	fi

screenshots: ## Save screenshots to ~/Documents/Screenshots
	@mkdir -p $(HOME)/Documents/Screenshots
	@defaults write com.apple.screencapture location -string "$(HOME)/Documents/Screenshots"
	@echo "✓ Screenshots -> ~/Documents/Screenshots"

ssh: ## Create SSH directory and config.local template, included from ~/.ssh/config; load keys on first use
	@echo "Setting up SSH..."
	@mkdir -p $(HOME)/.ssh && chmod 700 $(HOME)/.ssh
	@if [[ ! -f "$(HOME)/.ssh/config.local" ]]; then \
		printf "# Local SSH host definitions\n# Add your hosts here\n\n# Example:\n# Host myserver\n#   HostName 1.2.3.4\n#   User myuser\n#   Port 22\n#   IdentityFile ~/.ssh/id_ed25519\n" \
			> $(HOME)/.ssh/config.local && chmod 600 $(HOME)/.ssh/config.local; \
		echo "✓ Created ~/.ssh/config.local template"; \
	else \
		echo "✓ ~/.ssh/config.local already exists"; \
	fi
	@# Include must come first: after a Host block it would only apply to that host
	@cfg="$(HOME)/.ssh/config"; \
	if grep -qxF 'Include config.local' "$$cfg" 2>/dev/null; then \
		echo "✓ ~/.ssh/config already includes config.local"; \
	else \
		{ printf 'Include config.local\n\n'; if [ -f "$$cfg" ]; then cat "$$cfg"; fi; } > "$$cfg.tmp" \
			&& chmod 600 "$$cfg.tmp" && mv "$$cfg.tmp" "$$cfg" \
			&& echo "✓ Added 'Include config.local' to the top of ~/.ssh/config"; \
	fi
	@# Load keys into the agent on first use (passphrase once); on macOS also
	@# store the passphrase in the Keychain. Appended: first match wins in ssh
	@# config, so host-specific settings above still take precedence.
	@cfg="$(HOME)/.ssh/config"; \
	if grep -qiE '^[[:space:]]*AddKeysToAgent[[:space:]]' "$$cfg"; then \
		echo "✓ ~/.ssh/config already sets AddKeysToAgent"; \
	else \
		if [[ "$$(uname -s)" == Darwin ]]; then keychain='  UseKeychain yes\n'; else keychain=; fi; \
		printf "\nHost *\n  AddKeysToAgent yes\n$$keychain" >> "$$cfg" \
			&& echo "✓ Added AddKeysToAgent to ~/.ssh/config"; \
	fi

defaults: ## Apply macOS system defaults (macOS only)
	@[[ "$$(uname)" == "Darwin" ]] \
		&& zsh install/macos.sh \
		|| echo "⚠ Skipping macOS defaults on non-macOS system"

iterm: ## Let iTerm2 load and save its settings in iterm2/ of this repo (macOS only)
	@if [[ "$$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null)" == "$(DOTFILES)/iterm2" \
		&& "$$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null)" == 1 ]]; then \
		echo "✓ iTerm2 already uses $(DOTFILES)/iterm2"; \
	else \
		defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(DOTFILES)/iterm2"; \
		defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true; \
		echo "✓ iTerm2 set to use $(DOTFILES)/iterm2 (restart iTerm2)"; \
	fi
