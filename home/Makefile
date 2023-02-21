BREW_BIN := /opt/homebrew/bin/brew

all: macos

macos: brew nix python

brew:
	which brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash

brew-packages: brew
	$(BREW_BIN) bundle || true

nix:
	which nix || curl -L https://nixos.org/nix/install | sh

home-manager: nix
	which home-manager || (nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update && nix-shell '<home-manager>' -A install)

mamba:
	which micromamba || curl micro.mamba.pm/install.sh | zsh

python: mamba

version:
	nix --version && brew --version && micromamba --version

popclip:
	curl https://pilotmoon.com/popclip/extensions/ext/DOI.popclipextz -o "DOI.popclipextz"
	open "DOI.popclipextz"

cheatsheet:
	mkdir -p "$(HOME)/bin"
	curl https://cht.sh/:cht.sh > "$(HOME)/bin/cht.sh"
	chmod +x "$(HOME)/bin/cht.sh"

cheatsheet-uninstall:
	rm "$(HOME)/bin/cht.sh"

