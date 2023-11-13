BREW_BIN := /opt/homebrew/bin/brew

all: macos

macos: brew nix

brew:
	which brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash

brew-packages: brew
	$(BREW_BIN) bundle || true

nix:
	which nix || curl -L https://nixos.org/nix/install | sh

home-manager: nix
	which home-manager || (nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update && nix-shell '<home-manager>' -A install)


