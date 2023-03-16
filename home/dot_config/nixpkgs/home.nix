{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "zijin";
  home.homeDirectory = "/Users/zijin";

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.bat
    pkgs.bitwarden-cli
    pkgs.cht-sh
    pkgs.gdu
    pkgs.htop
    pkgs.gnumake
    pkgs.wget
    pkgs.ugrep
    pkgs.ripgrep
    pkgs.rclone
    pkgs.pipx
    pkgs.micromamba
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
    dotDir = ".config/zsh";
    initExtraBeforeCompInit = "source $HOME/.zshrc";
    autocd = true;
    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/aliases"; tags = ["from:oh-my-zsh"];}
        { name = "plugins/brew"; tags = ["from:oh-my-zsh"];}
        { name = "plugins/git"; tags = ["from:oh-my-zsh"];}
        { name = "~/.config/zsh/plugins"; tags = ["from:local"];}
      ];
    };
  };
  programs.git = {
    enable = true;
  };
  programs.fish.enable = true;
  programs.broot.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;
  programs.starship.enable = true;
}
