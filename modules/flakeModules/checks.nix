# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (config) devShells;

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
      checks = devShells // {
        inherit reuse;
      };
    };
}
