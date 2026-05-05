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
    { pkgs, config, ... }:
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
        machines = pkgs.runCommand "check-machines" {
          nativeBuildInputs = lib.map (name: nixosConfigurations.${name}.config.system.build.toplevel) (
            lib.attrNames (lib.removeAttrs nixosConfigurations [ "vps01" ])
          );
        } "mkdir $out";
        packages = pkgs.runCommand "check-packages" {
          nativeBuildInputs = lib.attrVals [ ] config.packages;
        } "mkdir $out";
      };
    };
}
