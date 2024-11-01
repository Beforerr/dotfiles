{
  pkgs,
  home-manager,
  ...
}:

let
  user = "zijin";
in
{
  imports = [
    ./system.nix
    # ./dock
    # ./homebrew
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  services.yabai.enable = true;

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = import ./home-manager.nix;
  };

}
