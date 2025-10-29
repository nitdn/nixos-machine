{
  flake.modules.nixos.vps =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.services.bind) domain_name IPv4 IPv6;
      journal_path = "/etc/bind/zones";

    in
    {
      options.services.bind = with lib; {
        domain_name = mkOption {
          type = types.str;
        };
        IPv4 = mkOption {
          type = types.str;
        };
        IPv6 = mkOption {
          type = types.str;
        };
      };
      config = {
        # Firewalls
        networking.firewall.allowedUDPPorts = [ 53 ];
        networking.firewall.allowedTCPPorts = [
          22
          53
          80
        ];
        services.bind = {
          domain_name = "slipstr.click";
          IPv4 = "147.93.97.244";
          IPv6 = "2a02:4780:12:d0d9::1";
        };

        systemd.tmpfiles.settings = {
          "10-bind" = {
            "${journal_path}" = {
              d = {
                mode = "0755";
                user = config.systemd.services.bind.serviceConfig.User;
              };
            };
          };
        };

        services.bind.enable = true;
        services.bind.extraOptions = ''
          recursion no;
        '';
        services.bind.extraConfig = ''
          include "${config.sops.secrets.named-tsig-key.path}";
        '';
        services.bind.zones."${domain_name}" = {
          extraConfig = ''
            update-policy { grant ${domain_name} zonesub TXT; };
            journal "${journal_path}/${domain_name}.jnl";
          '';
          master = true;
          file = pkgs.writeText "zone-${domain_name}" ''
            $ORIGIN ${domain_name}.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1
                         IN      NS      ns2

            @            IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}
                         IN      MX      10 mail
                         IN      TXT     "v=spf1 mx"


            www          IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}


            dns          IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}

            *.dns        IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}

            ns1          IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}

            ns2          IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}

            *            IN      A       ${IPv4}
                         IN      AAAA    ${IPv6}
          '';
        };

        security.acme = {
          acceptTerms = true;
          defaults.email = "admin+acme@${domain_name}";
          certs."wildcard.dns.${domain_name}" = {
            domain = "*.dns.${domain_name}";
            dnsProvider = "rfc2136";
            environmentFile = "${pkgs.writeText "nsupdate-creds" ''
              RFC2136_NAMESERVER=ns1.${domain_name}
              RFC2136_TSIG_FILE=${config.sops.secrets.acme-tsig-key.path}
            ''}";
          };
        };

        sops.secrets = {
          named-tsig-key = {
            owner = config.systemd.services.bind.serviceConfig.User;
            key = "tsig-key";
          };
          acme-tsig-key = {
            owner = config.systemd.services."acme-wildcard.dns.${domain_name}".serviceConfig.User;
            key = "tsig-key";
          };
        };
      };
    };
}
