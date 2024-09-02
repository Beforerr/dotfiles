{ pkgs, ... }:

with pkgs;
{
  imports = [
    ../shared/home-manager.nix
  ];

  home.packages = [
    mas
    dockutil
  ];
  programs = {
    vscode.enable = true;
  };
}
