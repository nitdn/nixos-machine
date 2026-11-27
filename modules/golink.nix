# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos.homelab =
    { unstablePkgs, ... }:
    let
      pkgs = unstablePkgs;
      dbDir = "/var/lib/golink/data";
      dbPath = "${dbDir}/golink.db";
    in
    {

      users.users.golink = {
        isSystemUser = true;
        group = "golink";
      };
      users.groups.golink = { };

      # Same layout as the upstream litestream NixOS test: the DB lives in a
      # setgid, group-writable subdirectory so files created by the litestream
      # user (db-wal, db-shm, ...) inherit the golink group.
      systemd.tmpfiles.settings."10-golink" = {
        "/var/lib/golink".d = {
          mode = "0750";
          user = "golink";
          group = "golink";
        };
        "${dbDir}".d = {
          mode = "2770";
          user = "golink";
          group = "golink";
        };
      };

      systemd.services.golink = {
        description = "Tailscale golink service";
        after = [
          "network-online.target"
        ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = "golink";
          Group = "golink";
          UMask = "0007";
          StateDirectoryMode = "0750";

          StateDirectory = "golink";
          WorkingDirectory = "/var/lib/golink";
          Environment = "HOME=/var/lib/golink";
          EnvironmentFile = "-/run/secrets/golink.env";

          # Switch to WAL before golink opens the DB, so litestream never has
          # to flip the journal mode under a live connection.
          # (runs as the golink user, so any file it creates is owned by it)
          ExecStartPre = "${pkgs.sqlite}/bin/sqlite3 ${dbPath} 'PRAGMA journal_mode=WAL;'";
          ExecStart = "${pkgs.golink}/bin/golink --sqlitedb ${dbPath}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
