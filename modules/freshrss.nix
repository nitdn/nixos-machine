# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

_: {
  flake.modules.nixos.homelab =
    { pkgs, config, ... }:
    let
      username = config.services.freshrss.user or "freshrss";
      tailnet_name = "curlew-rankine.ts.net";
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
      services.nginx.virtualHosts."_" = {
        locations."/" = {
          return = 404;
        };
      };

      services.freshrss = {
        enable = true;
        baseUrl = "https://${username}.${tailnet_name}";
        api.enable = true;
        passwordFile = "/run/secrets/freshrss";
        virtualHost = "${username}.${tailnet_name}";
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

      systemd.services.freshrss-config = {
        environment = {
          OIDC_ENABLED = "true";
          OIDC_PROVIDER_METADATA_URL = "https://idp.${tailnet_name}/.well-known/openid-configuration";
          OIDC_REMOTE_USER_CLAIM = "email";
          OIDC_SCOPES = "email";

        };
        serviceConfig.EnvironmentFile = [
          config.sops.secrets.freshrss-oidc.path
          "/var/lib/freshrss/oidc-crypto-key"
        ];

      };
      sops.secrets.freshrss-oidc = {
        owner = username;
      };
    };
}
