{ config, pkgs, lib, home-manager, ... }:

let
  user = "zijin";
  # Define the content of your file as a derivation
  shared-programs = import ../shared/programs.nix { inherit config pkgs lib; };
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix {};
    file = lib.mkMerge [
      sharedFiles
      { "emacs-launcher.command".source = myEmacsLauncher; }
    ];
    stateVersion = "23.11";
  };
  programs = shared-programs // {};
}
