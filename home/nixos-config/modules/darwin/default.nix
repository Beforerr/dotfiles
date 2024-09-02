{ config, pkgs, lib, home-manager, ... }:

let
  user = "zijin";
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      "Bitwarden" = 1352778147;
      "DwellClick" = 402414007;
      "Flow" = 1423210932;
      "Gapplin" = 768053424;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = import ./home-manager.nix;
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app"; }
    {
      path = "~/projects";
      section = "others";
    }
    {
      path = "~/Downloads";
      section = "others";
    }
  ];

}
