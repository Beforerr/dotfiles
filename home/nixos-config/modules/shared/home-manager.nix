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
    dotDir = "$HOME/.config/zsh";
    syntaxHighlighting.enable = true;
    initExtraFirst = "source $HOME/.zshrc";
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
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
  direnv.enable = true;
  eza.enable = true;
  fzf.enable = true;
  zoxide.enable = true;
  starship.enable = true;
  }
