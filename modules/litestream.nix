# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos.homelab =
    { config, pkgs, ... }:
    let
      golinkRestore = pkgs.writeShellApplication {
        name = "golink-restore";
        runtimeInputs = [
          config.services.litestream.package
          pkgs.sqlite
          pkgs.coreutils
          pkgs.systemd
        ];
        text = ''
          usage() {
            echo "usage: golink-restore [-t|--timestamp TIME] [-y|--yes]"
            echo "  TIME is local time, anything GNU date accepts, e.g."
            echo "    '2026-11-28 17:00'  '10 minutes ago'  'yesterday 5pm'"
          }

          args=()
          assume_yes=0
          while [ $# -gt 0 ]; do
            case "$1" in
              -t|--timestamp)
                [ $# -ge 2 ] || { usage; exit 2; }
                # human time in the machine's local zone -> UTC RFC3339 for litestream
                ts=$(date -u -d "$2" +%Y-%m-%dT%H:%M:%SZ) \
                  || { echo "cannot parse time: $2" >&2; exit 2; }
                echo "Restoring state as of $ts (UTC), from input: $2"
                args+=(-timestamp "$ts")
                shift 2
                ;;
              -y|--yes) assume_yes=1; shift ;;
              -h|--help) usage; exit 0 ;;
              *) usage; exit 2 ;;
            esac
          done

          [ "$(id -u)" -eq 0 ] || { echo "must run as root" >&2; exit 1; }

          db=/var/lib/golink/data/golink.db

          set -a
          # shellcheck source=/dev/null
          . ${config.sops.templates."litestream.env".path}
          set +a

          # 1. Restore into a scratch dir first; the live DB is untouched so far.
          tmp=$(mktemp -d /var/lib/golink/restore.XXXXXX)
          trap 'rm -rf "$tmp"' EXIT
          echo "Restoring from replica into $tmp ..."
          litestream restore -config /etc/litestream.yml "''${args[@]}" -o "$tmp/golink.db" "$db"

          # 2. Verify before replacing anything.
          [ "$(sqlite3 "$tmp/golink.db" 'PRAGMA integrity_check;')" = ok ] \
            || { echo "integrity_check failed; live DB left untouched" >&2; exit 1; }
          echo "Restored DB is OK, links: $(sqlite3 "$tmp/golink.db" 'select count(*) from Links;')"

          if [ "$assume_yes" -ne 1 ]; then
            read -r -p "Stop golink + litestream and replace the live DB? [y/N] " ans
            [ "$ans" = y ] || { echo "aborted"; exit 1; }
          fi

          # 3. Swap, keeping the old data dir aside.
          systemctl stop litestream golink
          bad=/var/lib/golink/data.bad.$(date +%Y%m%d-%H%M%S)
          if [ -d /var/lib/golink/data ]; then mv /var/lib/golink/data "$bad"; fi
          install -d -o golink -g golink -m 2770 /var/lib/golink/data
          install -o golink -g golink -m 660 "$tmp/golink.db" "$db"
          systemctl start golink litestream

          echo "Done. Check http://go/ and: journalctl -u litestream"
          [ ! -d "$bad" ] || echo "Old data kept at $bad (delete when satisfied)"
        '';
      };
    in
    {
      # 1. Declare Garage S3 credentials from your encrypted SOPS file
      sops.secrets = {
        "garage/golink_access_key_id" = { };
        "garage/golink_secret_access_key" = { };
      };

      # 2. Render KEY=VALUE environment file in /run/secrets/rendered/
      sops.templates."litestream.env".content = ''
        LITESTREAM_ACCESS_KEY_ID=${config.sops.placeholder."garage/golink_access_key_id"}
        LITESTREAM_SECRET_ACCESS_KEY=${config.sops.placeholder."garage/golink_secret_access_key"}
      '';

      # 3. Shared upstream module; the litestream user gets golink's group
      users.users.litestream.extraGroups = [ "golink" ];

      services.litestream = {
        enable = true;
        environmentFile = config.sops.templates."litestream.env".path;
        settings = {
          dbs = [
            {
              path = "/var/lib/golink/data/golink.db";
              replicas = [
                {
                  type = "s3";
                  bucket = "golink-backups";
                  path = "golink.db";
                  endpoint = "https://garage.curlew-rankine.ts.net";
                  region = "garage";
                  force-path-style = true;
                }
              ];
            }
          ];
        };
      };

      # `sudo golink-restore [-t UTC_TIME]` restores the DB from the replica
      environment.systemPackages = [ golinkRestore ];

      systemd.services.litestream = {
        after = [ "golink.service" ];
        requires = [ "golink.service" ];
        serviceConfig = {
          # From the upstream test: make sure the db, -wal and -shm files are
          # group-readable/writable before litestream starts ("+" = run as root).
          ExecStartPre = "+${pkgs.runtimeShell} -c 'chmod g+rw /var/lib/golink/data/golink.db*'";
        };
      };
    };
}
