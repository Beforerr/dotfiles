{ config, pkgs, lib, home-manager, ... }:

let
  user = "zijin";
in
{
  imports = [
   ./dock
   ./homebrew/default.nix
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
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
