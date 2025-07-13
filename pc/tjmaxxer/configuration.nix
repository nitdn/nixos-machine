{ pkgs, config, ... }:
{
  imports = [
    ../configuration.nix
    ./hardware-configuration.nix
    ./systemd.nix
  ];

  networking.hostName = "tjmaxxer"; # Define your hostname.
}
