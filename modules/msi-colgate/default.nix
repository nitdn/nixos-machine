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
in
{

  flake.modules.nixos.msi-colgate = {
    hardware.facter.reportPath = ./facter.json;
    system.stateVersion = "25.05"; # Did you read the comment?
    networking = {
      hostName = "msi-colgate";
      interfaces = {
        enp34s0 = {
          wakeOnLan.enable = true;
        };
      };
      firewall = {
        allowedUDPPorts = [ 9 ];
      };
    }; # Define your hostname.

  };

  flake.nixosConfigurations.msi-colgate = inputs.nixpkgs.lib.nixosSystem {
    modules = lib.attrValues { inherit (nixosModules) pc work msi-colgate; };
  };
}
