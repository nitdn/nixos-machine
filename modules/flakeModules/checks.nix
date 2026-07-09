# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
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
          reuse = pkgs.testers.runCommand {
            name = "reuse-lint";
            src = self;
            nativeBuildInputs = [ pkgs.reuse ];
            script = ''
              cd $src
              reuse lint
              touch $out
            '';
          };
        };
    };
}
