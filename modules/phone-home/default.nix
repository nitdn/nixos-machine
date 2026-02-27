# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          config.flake.modules.nixos.droid
          # list of extra modules for Nix-on-Droid system
          # { nix.registry.nixpkgs.flake = nixpkgs; }
          # ./path/to/module.nix

          # or import source out-of-tree modules like:
          # flake.nixOnDroidModules.module
        ];

        # list of extra special args for Nix-on-Droid modules
        inherit pkgs;
      };
    };
}
