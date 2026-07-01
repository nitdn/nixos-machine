# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  description = "A variety of machines powered by NixOS™";
  outputs =
    { self, ... }@args:
    let
      inputs = (import ./.tack) { overrides = args.tackOverrides or { }; };
      inputs' = inputs // {
        self = self // {
          inputs = inputs';
        };
      };

    in
    inputs.flake-parts.lib.mkFlake
      {
        inputs = inputs';
      }
      (
        { lib, ... }:
        let
          import-tree = import ./recursiveImportModules.nix lib;
        in
        {
          imports = import-tree ./modules;
        }
      );

  nixConfig = {
    extra-substituters = [
      "https://machines.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "machines.cachix.org-1:imnXlKFUc4Iaedv6469v6TO37ruiNh6OfJN4le5bqdE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

}
