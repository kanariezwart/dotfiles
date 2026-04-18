OTFILES := $(shell pwd)
PACKAGES := zsh git shell

.PHONY: install stow unstow update brew

install: brew stow

brew:
	brew bundle --file=install/Brewfile

stow:
	@for package in $(PACKAGES); do \
		echo "Stowing $$package..."; \
		stow --target=$(HOME) $$package; \
	done

unstow:
	@for package in $(PACKAGES); do \
		echo "Unstowing $$package..."; \
		stow --delete --target=$(HOME) $$package; \
	done

update:
	git pull
	$(MAKE) stow
test:
	@echo "Simulating stow..."
	@for package in $(PACKAGES); do \
		echo "Testing $$package..."; \
		stow --simulate --target=$(HOME) $$package; \
	done
	@echo "All packages OK!"
