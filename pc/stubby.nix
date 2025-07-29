{ pkgs, config, ... }:
let
  hostname = config.networking.hostName;
  tls_auth_name = "id-${hostname}.dns.slipstr.click";
in
{
  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      upstream_recursive_servers = [
        {
          address_data = "147.93.97.244";
          inherit tls_auth_name;
        }
        {
          address_data = "2a02:4780:12:d0d9::1";
          inherit tls_auth_name;
        }
      ];
    };
  };
}
