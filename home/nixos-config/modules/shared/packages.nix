{ pkgs }:

with pkgs;
[
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
  hyperfine

  pandoc
  librsvg

  # Encryption and security tools

  # Cloud-related tools and SDKs

  # Media-related packages

  # Nix-related tools
  nixfmt-rfc-style

  # Rust development tools
  rustup

  # Node.js development tools

  # Python development tools
  pixi
  uv
  # disable pdm as it fails to create virtualenv https://github.com/NixOS/nixpkgs/issues/225730
  # pdm
  ruff

  # Text and terminal utilities
  bat
  htop
  ugrep
  ripgrep
  yq-go
]
