# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  inputs,
  moduleWithSystem,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
  inherit (config.meta) username;
  inherit (config.flake.modules) generic;
in
{
  flake.modules.nixos.disko-elysium = moduleWithSystem (
    { pkgs, ... }:
    let
      inherit homeModules;
    in
    {
      imports = [
        generic.light
      ];
      # boot.loader.efi.canTouchEfiVariables = false;
      networking.useDHCP = true;
      hardware.facter.reportPath = ./facter.json;
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
        ]; # Enable ‘sudo’ for the user.
        packages = with pkgs; [
          tree
        ];
      };
      home-manager.users."${username}" = homeModules.pc;
      environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
      ];
      networking.hostName = "disko-elysium"; # Define your hostname.
      system.stateVersion = "25.05"; # Did you read the comment?
    }
  );

  flake.nixosConfigurations.disko-elysium = inputs.nixpkgs.lib.nixosSystem {
    modules = with nixosModules; [
      pc
      disko-elysium
      hmBase
    ];
  };
}
