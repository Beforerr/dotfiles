#!/bin/bash
if ! command -v nix &> /dev/null; then
	curl -L https://nixos.org/nix/install | sh
fi

if ! command -v home-manager &> /dev/null; then
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update 
	nix-shell '<home-manager>' -A install
fi