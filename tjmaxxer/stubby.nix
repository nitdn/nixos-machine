{ pkgs, config, ... }:
{
  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      upstream_recursive_servers = [
        {
          address_data = "147.93.97.244";
          tls_auth_name = "id-tjmaxxer.dns.slipstr.click";
          tls_pubkey_pinset = [
            {
              digest = "sha256";
              value = "p/7EVb1sOmy28MlCQ9v9pCO/+3IqAuBmShW7YW59N6w=";
            }
          ];
        }
        {
          address_data = "2a02:4780:12:d0d9::1";
          tls_auth_name = "id-tjmaxxer.dns.slipstr.click";
          tls_pubkey_pinset = [
            {
              digest = "sha256";
              value = "p/7EVb1sOmy28MlCQ9v9pCO/+3IqAuBmShW7YW59N6w=";
            }
          ];
        }
      ];
    };
  };
}
