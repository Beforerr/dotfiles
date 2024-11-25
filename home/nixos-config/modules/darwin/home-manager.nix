{ pkgs, ... }:

with pkgs;
{
  imports = [
    ../shared/home-manager.nix
  ];

  home.packages = [
    mas
  ];
  programs = {
    # vscode.enable = true;
  };
}
