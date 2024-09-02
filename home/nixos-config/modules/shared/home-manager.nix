{ config, pkgs, lib, ... }:

let name = "Beforerr";
    user = "zijin";
    email = "zzj956959688@gmail.com"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "$HOME/.config/zsh";
    initExtraFirst = "source $HOME/.zshrc";
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

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	      editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };
  home-manager.enable = true;
  vscode.enable = true;

  aria2.enable = true;
  broot.enable = true;
  direnv.enable = true;
  eza.enable = true;
  fzf.enable = true;
  zoxide.enable = true;
  starship.enable = true;
  yazi.enable = true;

  # nushell.enable = true;
  # fish.enable = true;
  }
