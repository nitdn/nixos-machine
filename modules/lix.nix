# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      nix.package = pkgs.lix;
      programs.direnv.nix-direnv.package = pkgs.lixPackageSets.latest.nix-direnv;
    };
}
