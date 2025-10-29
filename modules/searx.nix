{
  flake.modules.nixos.vps =
    { config, ... }:
    let
      inherit (config.services.bind) domain_name;
    in
    {
      # This is the actual specification of the secrets.
      sops.secrets = {
        searx = { };
      };
      services.nginx.virtualHosts = {
        "search.${domain_name}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:8001";
          };
        };
      };
      services.searx = {
        enable = true;
        redisCreateLocally = true;
        settings = {
          server.port = 8001;
          server.bind_address = "::1";
          server.secret_key = config.sops.secrets.searx.path;

        };
      };

    };
}
