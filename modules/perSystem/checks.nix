# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (config.flake) nixosConfigurations;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        reuse =
          pkgs.runCommand "reuse"
            {
              src = inputs.self.outPath;
              nativeBuildInputs = [ pkgs.reuse ];
            }
            ''
              cd $src
              reuse lint
              mkdir $out
            '';
      }
      // lib.genAttrs [ "tjmaxxer" "msi-colgate" "disko-elysium" ] (
        name: nixosConfigurations.${name}.config.system.build.toplevel
      );
    };
}
