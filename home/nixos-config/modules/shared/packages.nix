{ pkgs }:

with pkgs; [
  # General packages for development and system management
  ## Tier 1
  just
  pre-commit
  ## Tier 2
  btop
  coreutils
  gdu
  goku
  killall
  watchexec
  wget
  rclone
  zip

  # Encryption and security tools

  # Cloud-related tools and SDKs

  # Media-related packages

  # Nix-related tools
  nixfmt-rfc-style

  # Node.js development tools

  # Python development tools
  pixi
  pdm
  ruff

  # Text and terminal utilities
  bat
  htop
  ripgrep
  yq-go
]
