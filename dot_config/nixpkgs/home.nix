{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "zijin";
  home.homeDirectory = "/Users/zijin";

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.bat
    pkgs.fish
    pkgs.gdu
    pkgs.htop
    pkgs.gnumake
    pkgs.wget
    pkgs.ugrep
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd = true;
  };
  programs.zoxide.enable = true;
  programs.direnv.enable = true;
  programs.git = {
    enable = true;
  };
}
