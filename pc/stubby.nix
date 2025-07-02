{ pkgs, config, ... }:
{
  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      upstream_recursive_servers = [
        {
          address_data = "147.93.97.244";
          tls_auth_name = "id-tjmaxxer.dns.slipstr.click";
        }
        {
          address_data = "2a02:4780:12:d0d9::1";
          tls_auth_name = "id-tjmaxxer.dns.slipstr.click";
        }
      ];
    };
  };
}
