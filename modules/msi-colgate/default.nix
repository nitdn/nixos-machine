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
    networking.hostName = "msi-colgate"; # Define your hostname.
  };

  flake.nixosConfigurations.msi-colgate = inputs.nixpkgs.lib.nixosSystem {
    modules = lib.attrValues { inherit (nixosModules) pc work msi-colgate; };
  };
}
