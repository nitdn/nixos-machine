{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../helix.nix
    ../gitui.nix
  ];

  # Read the changelog before changing this value
  home.stateVersion = "24.05";

  # insert home-manager config
}
