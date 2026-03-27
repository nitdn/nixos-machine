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
          src = ./.;
          nativeBuildInputs = lib.map (name: nixosConfigurations.${name}.config.system.build.toplevel) [
            "tjmaxxer"
            "msi-colgate"
            "disko-elysium"
          ];
        } "mkdir $out";
      };
    };
}
