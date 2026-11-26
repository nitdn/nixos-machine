# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

_: {
  flake.modules.nixos.homelab =
    {
      pkgs,
      config,
      ...
    }:
    let
      username = config.services.freshrss.user or "freshrss"; # always http
      tailnet_name = "curlew-rankine.ts.net";
      virtualHost = "${username}.${tailnet_name}";
      inherit (pkgs) freshrss-extensions;
      inherit (freshrss-extensions) youtube reddit-image;
    in
    {
      services.postgresql = {
        enable = true;
        ensureDatabases = [ username ];
        ensureUsers = [
          {
            name = username;
            ensureDBOwnership = true;
          }
        ];
      };

      users.users.${config.services.caddy.user}.extraGroups = [ config.services.tailscaleAuth.group ];

      services.caddy.globalConfig = ''
        servers {
          listener_wrappers {
            proxy_protocol {
              timeout 2s
              allow 127.0.0.1/24 ::1/128
              deny 10.0.0.0/8
              fallback_policy reject
            }
            tls
          }
        }
      '';
      services.caddy.virtualHosts."${virtualHost}".extraConfig = ''
        # Forward Auth
        forward_auth unix/${config.services.tailscaleAuth.socketPath} {
        uri /auth
        header_up Remote-Addr {remote_host}
        header_up Remote-Port {remote_port}
        header_up Original-URI {uri}
        copy_headers {
          Tailscale-User>X-Webauth-User
          Tailscale-Name>X-Webauth-Name
          Tailscale-Login>X-Webauth-Login
          Tailscale-Tailnet>X-Webauth-Tailnet
          Tailscale-Profile-Picture>X-Webauth-Profile-Picture
          }
        }
      '';

      services.tailscaleAuth.enable = true;
      services.tailscale = {
        permitCertUid = config.services.caddy.user;
      };
      # {
      #   locations."~ ^.+?\\.php(/.*)?$".fastcgiParams = {
      #     REMOTE_USER = "$http_tailscale_user_login";
      #   };
      # };

      services.freshrss = {
        enable = true;
        baseUrl = "https://${virtualHost}";
        api.enable = true;
        authType = "http_auth";
        passwordFile = "/run/secrets/freshrss";
        webserver = "caddy";
        inherit virtualHost;
        extensions = [
          youtube

          reddit-image

          (freshrss-extensions.buildFreshRssExtension {
            FreshRssExtUniqueId = "xExtension-XProfiles";
            pname = "xExtension-XProfiles";
            version = "0.1.4";
            src = pkgs.fetchFromGitHub {
              owner = "shcheglovnd";
              repo = "FreshRSS-xExtension-XProfiles";
              rev = "b7cf9a0d0af233fb88cd2f3f99df8f8b6ee6b312";
              hash = "sha256-hKDa5+kcEFNvIEkvhHKJMHY++M5fmDjzrR+i2a0e28U=";
            };
          })

        ];
        database = {
          type = "pgsql";
          host = "/run/postgresql";
        };
      };

      services.tailscale.serve.services.freshrss.endpoints."tcp:443" = "tcp://localhost:443";
      services.tailscale.serve.services.freshrss.endpoints."tcp:80" = "tcp://localhost:80";
    };
}
