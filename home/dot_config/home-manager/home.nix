{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "zijin";
  home.homeDirectory = "/Users/zijin";

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.just
    pkgs.bat
    pkgs.bitwarden-cli
    pkgs.gdu
    pkgs.htop

    pkgs.gnumake
    pkgs.cmake

    pkgs.wget
    pkgs.ugrep
    pkgs.ripgrep
    pkgs.yq-go
    pkgs.rclone
    # pkgs.pipx # Note: outdated
    pkgs.temurin-bin
    # pkgs.ruby
    # pkgs.rustup
    pkgs.pixi
    pkgs.nodejs # Note: The operation was rejected by your operating system (one may use `nvm` instead).
    pkgs.pandoc
    pkgs.librsvg
    # pkgs.neovide # (GUI for neovim)
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    initExtraFirst = "source $HOME/.zshrc";
    autocd = true;
    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/aliases"; tags = ["from:oh-my-zsh"];}
        { name = "plugins/brew"; tags = ["from:oh-my-zsh"];}
        { name = "plugins/git"; tags = ["from:oh-my-zsh"];}
        { name = "hlissner/zsh-autopair"; tags = ["defer:2"];}
        { name = "~/.config/zsh/plugins"; tags = ["from:local"];}
      ];
    };
  };
  programs.git.enable = true;
  programs.emacs.enable = true;
  programs.neovim.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;

  programs.aria2.enable = true;
  programs.broot.enable = true;
  programs.direnv.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.starship = {
    enable = true;
    settings.battery.disabled = true;
  };

  # services.emacs.enable = true; #: The module services.emacs does not support your platform.
}
