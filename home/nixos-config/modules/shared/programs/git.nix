{ ... }:

let
  name = "Beforerr";
  email = "zzj956959688@gmail.com";
in

{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
      ".DS_Store"
    ];
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
}
