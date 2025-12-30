# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, config, ... }:
{
  flake.nixosConfigurations.vps01 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      config.flake.modules.nixos.vps
      {
        config.facter.reportPath =
          if builtins.pathExists ./facter.json then
            ./facter.json
          else
            throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./vps/facter.json`?";
      }
    ];
  };
}
