#!/bin/bash
# Check if the user has sudo privileges
if sudo -l -U zijin  2>&1 | grep -q '(.*) ALL' ; then
    echo "This user has sudo privileges."
else
    echo "This user does NOT have sudo privileges."
	exit
fi

echo "Installing 'nix' package manager..."
if ! command -v nix; then
	curl -L https://nixos.org/nix/install | sh
fi

if command -v home-manager; then
  echo "Installing packages with 'home manager'..."
	home-manager switch
else
	echo "Home manager is not installed. Please install it first."
fi

echo "You may need to change login shell to zsh (nix-shell) with ..."
echo '"sudo chsh -s $(which zsh) $(whoami)"'
