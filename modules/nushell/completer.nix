# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, ... }: {
  flake.modules.nixos.pc =
    { config, ... }:
    let
      inshellahPackage = inputs.inshellah.packages.${config.nixpkgs.hostPlatform.system}.default;
    in
    {
      imports = [ inputs.inshellah.nixosModules.default ];

      programs.inshellah = {
        enable = true;
        package = inshellahPackage;
        nushellPackage = config.wrappers.nushell-pc.wrapper;
      };
    };
}
