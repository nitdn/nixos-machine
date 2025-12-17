{
  flake.modules.nixos.vps =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        ensureDatabases = [ "mydatabase" ];
        identMap = ''
          # ArbitraryMapName  systemUser  DBUser
            superuser_map     root        postgres
            superuser_map     postgres    postgres
            superuser_map     /^(.*)$     \1 # Let other names log in as themselves
        '';
        authentication = pkgs.lib.mkOverride 10 ''
          # type   database   DBuser    auth-method   optional_ident_map
          # local  all        all       trust
            local  all        postgres  peer
            local  sameuser   all       peer          map=superuser_map
            host   sameuser   all       127.0.0.1/32  scram-sha-256
            host   sameuser   all       ::1/128       scram-sha-256
            host   sameuser   blocky    all           scram-sha-256
        '';
      };
      services.postgresqlBackup = {
        enable = true;
        startAt = config.system.autoUpgrade.dates;
      };

      services.nginx.streamConfig = ''
        server {
          listen 9856;
          proxy_connect_timeout 60s;
          proxy_socket_keepalive on;
          proxy_pass localhost:5432;
        }
      '';
      networking.firewall.allowedTCPPorts = [ 9856 ];

      environment.systemPackages = [
        (
          let
            # XXX specify the postgresql package you'd like to upgrade to.
            # Do not forget to list the extensions you need.
            newPostgres = pkgs.postgresql_17.withPackages (_pp: [
              # pp.plv8
            ]);
            cfg = config.services.postgresql;
          in
          pkgs.writeScriptBin "upgrade-pg-cluster" ''
            set -eux
            # XXX it's perhaps advisable to stop all services that depend on postgresql
            systemctl stop postgresql

            export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
            export NEWBIN="${newPostgres}/bin"

            export OLDDATA="${cfg.dataDir}"
            export OLDBIN="${cfg.finalPackage}/bin"

            install -d -m 0700 -o postgres -g postgres "$NEWDATA"
            cd "$NEWDATA"
            sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

            sudo -u postgres "$NEWBIN/pg_upgrade" \
              --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
              --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
              "$@"
          ''
        )
      ];
      sops.secrets.pgtls-crt = {
        format = "binary";
        owner = config.systemd.services.postgresql.serviceConfig.User;
        sopsFile = ../secrets/postgres-server.crt;
        path = "${config.services.postgresql.dataDir}/server.crt";
      };
      sops.secrets.pgtls-key = {
        format = "binary";
        owner = config.systemd.services.postgresql.serviceConfig.User;
        sopsFile = ../secrets/postgres-server.key;
        path = "${config.services.postgresql.dataDir}/server.key";
      };

    };
}
