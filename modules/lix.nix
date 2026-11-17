# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    let
      inherit (pkgs.lixPackageSets.latest) lix;
    in
    {
      nix.package = lix;
    };
  flake.modules.nixos.homelab =
    { pkgs, ... }:

    let
      inherit (pkgs.lixPackageSets.latest) nix-serve-ng;
    in
    {
      services.nix-serve.package = nix-serve-ng;
    };
}
