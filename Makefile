
BREW_BIN := /opt/homebrew/bin/brew

brew-packages:
	$(BREW_BIN) bundle --file=$(HOME)/install/Brewfile || true