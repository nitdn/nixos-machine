# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    let
      targetFile = pkgs.writeText "houses.smfh" ''
        hello
        i am fine thank you
        do we live in a society
      '';

    in
    {
      systemd.user.services.smfh-relink = {
        enable = true;
        description = "Links smfh files on rebuild";
        restartTriggers = [ targetFile ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "smfh-relink" ''
            ${pkgs.coreutils}/bin/cat ${targetFile};
          '';
        };
      };
    };
}
