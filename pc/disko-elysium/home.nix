{ pkg, lib, ... }:
{
  imports = [
    ../home.nix
  ];
  programs.helix.settings.theme = "ayu_light";
}
