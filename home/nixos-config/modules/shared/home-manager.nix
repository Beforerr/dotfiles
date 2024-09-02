{ pkgs, ... }:

{
  home = {
    stateVersion = "24.05";
    packages = import ./packages.nix { inherit pkgs; };
  };
  programs = import ./programs.nix { inherit pkgs; };
}
