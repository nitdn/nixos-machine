# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  config,
  ...
}:
let
  inherit (config.flake) nixosConfigurations;
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (config) devShells;

      nixosMachines = lib.genAttrs (lib.removeAttrs nixosConfigurations [ "vps01" ] |> lib.attrNames) (
        name: nixosConfigurations.${name}.config.system.build.toplevel
      );
      reuse = pkgs.testers.runCommand {
        name = "reuse-lint";
        src = ../../.;
        nativeBuildInputs = [ pkgs.reuse ];
        script = ''
          cd $src
          reuse lint
          touch $out
        '';
      };
    in
    {
      checks =
        nixosMachines
        // devShells
        // {
          inherit reuse;
        };
    };
}
