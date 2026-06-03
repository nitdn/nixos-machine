# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  self,
  ...
}:
let
  inherit (self) nixosConfigurations;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks =
        lib.genAttrs (lib.attrNames (lib.removeAttrs nixosConfigurations [ "vps01" ])) (
          name: nixosConfigurations.${name}.config.system.build.toplevel
        )
        // {
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
        };
    };
}
