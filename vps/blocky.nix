{
  pkgs,
  config,
  ...
}:
let
  certFile = "/var/lib/acme/wildcard.dns.${domain_name}/fullchain.pem";
  keyFile = "/var/lib/acme/wildcard.dns.${domain_name}/key.pem";
  inherit (config.services.bind) domain_name;
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

  users.extraGroups = {
    blocky-creds = { };
  };
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
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
        "https://dns.google/dns-query" # Some URLs do not work with CF
      ];
      upstreams.userAgent = "blocky-slipstr";
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
      #Enable Blocking of certian domains.
      blocking = {
        denylists = {
          #Adblocking
          ads = [
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.medium.txt"
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
        };
      };
      inherit certFile keyFile;
      ede.enable = true;
      ecs = {
        # optional: if the request ecs option with a max sice mask the address will be used as client ip
        useAsClient = true;
        # optional: if the request contains a ecs option it will be forwarded to the upstream resolver
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
}
