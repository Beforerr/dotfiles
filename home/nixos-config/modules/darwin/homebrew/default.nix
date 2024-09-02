{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = [ "beforerr/beforerr" ];
    casks = import ./casks.nix { };
    masApps = import ./masApps.nix { };
  };
}
