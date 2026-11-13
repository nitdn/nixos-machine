# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  config,
  inputs,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
  inherit (config.meta) username;
in
{
  flake.modules.nixos.disko-elysium =
    { pkgs, ... }:
    {
      # boot.loader.efi.canTouchEfiVariables = false;
      hardware.facter.reportPath = ./facter.json;
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
        ]; # Enable ‘sudo’ for the user.
        packages = [
          pkgs.tree
        ];
      };
      environment.systemPackages = [
        pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        pkgs.wget
      ];
      networking.hostName = "disko-elysium"; # Define your hostname.
      system.stateVersion = "25.05"; # Did you read the comment?
      hardware.graphics = {
        # enable32Bit = true;
      };
      hardware.enableRedistributableFirmware = true;
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
      };

      networking = {
        interfaces = {
          enp0s20f0u1u4 = {
            wakeOnLan.enable = true;
          };
        };
        firewall = {
          allowedUDPPorts = [ 9 ];
        };
      };

      services.auto-cpufreq.enable = true;
      services.auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };

    };

  flake.nixosConfigurations.disko-elysium = inputs.nixpkgs.lib.nixosSystem {
    modules = lib.attrValues { inherit (nixosModules) pc disko-elysium; };
  };
}
