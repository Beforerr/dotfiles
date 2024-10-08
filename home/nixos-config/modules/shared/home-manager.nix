{ pkgs, ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/zsh.nix
  ];

  home = {
    stateVersion = "24.05";
    packages = import ./packages.nix { inherit pkgs; };
  };
  programs = import ./programs.nix { };
}
