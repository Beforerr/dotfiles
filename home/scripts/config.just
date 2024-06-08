docks:
  command -v dockutil || nix-env -i dockutil
  dockutil --remove all --no-restart
  dockutil --add /System/Applications/Launchpad.app --no-restart
  dockutil --add '~/projects' --no-restart
  dockutil --add '~/Downloads'
