# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.vps =
    {
      config,
      ...
    }:
    let
      inherit (config.services.bind) domain_name;
      certFile = "/var/lib/acme/wildcard.dns.${domain_name}/fullchain.pem";
      keyFile = "/var/lib/acme/wildcard.dns.${domain_name}/key.pem";
      blocky-group = config.users.groups.blocky-creds.name;
    in
    {

      systemd.services.blocky = {
        environment.PGPASSFILE = config.sops.secrets.pgpass.path;
        serviceConfig = {
          SupplementaryGroups = [
            "acme"
            blocky-group
          ];
        };
      };
      services.nginx.virtualHosts = {
        "dns.${domain_name}" = {
          forceSSL = true;
          enableACME = true;
          locations."/dns-query" = {
            proxyPass = "http://localhost:4000";
          };
          locations."/" = {
            basicAuthFile = ../secrets/blocky-htpasswd;
            proxyPass = "http://localhost:4000";
          };
        };
      };

      users.extraGroups = {
        blocky-creds = { };
      };
      sops.secrets.blocky_initdb = {
        owner = config.systemd.services.postgresql.serviceConfig.User;
        sopsFile = ../secrets/postgres-secrets.yaml;
      };
      services.postgresql.initialScript = config.sops.secrets.blocky_initdb.path;

      sops.secrets.pgpass = {
        sopsFile = ../secrets/postgres-secrets.yaml;
        group = blocky-group;
        mode = "0440";
      };

      networking.firewall.allowedTCPPorts = [
        443
        853
      ];

      services.blocky = {
        enable = true;

        settings = {
          caching = {
            minTime = "5m";
            maxTime = "30m";
            prefetching = true;
          };
          ports.dns = 153;
          ports.tls = 853;
          ports.http = 4000;
          upstreams.groups.default = [
            # "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
            "https://dns11.quad9.net/dns-query"
            "https://dns.google/dns-query" # Some URLs do not work with CF

          ];
          upstreams.userAgent = "blocky-slipstr";
          # For initially solving DoH/DoT Requests when no system Resolver is available.
          bootstrapDns = {
            upstream = "https://dns.google/dns-query";
            ips = [
              "8.8.8.8"
              "8.8.4.4"
              "2001:4860:4860::8888"
              "2001:4860:4860::8844"
            ];
          };
          #Enable Blocking of certain domains.
          blocking = {
            denylists = {
              #Adblocking
              ads = [
                "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              ];
              #Another filter for blocking adult sites
              adult = [
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/gambling.txt"
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/nosafesearch.txt"
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/nsfw.txt"
              ];
              #You can add additional categories
            };
            #Configure what block categories are used
            clientGroupsBlock = {
              default = [ "ads" ];
              "family*" = [
                "ads"
                "adult"
              ];
              "bypass*" = [ ];
            };
          };
          inherit certFile keyFile;
          ede.enable = true;
          ecs = {
            useAsClient = true;
            forward = true;
          };
          prometheus = {
            enable = true;
          };
          queryLog = {
            type = "postgresql";
            target = "postgres://blocky@127.0.0.1/blocky";
          };
        };
      };
    };
}
