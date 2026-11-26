# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
_:
let
  svcHostname = "status.curlew-rankine.ts.net";
in
{
  flake.modules.nixos = {
    homelab =
      {
        unstablePkgs,
        config,
        lib,
        ...
      }:
      let
        cfg = config.services.beszel.hub;
        inherit (cfg) port;
      in
      {
        systemd.services.beszel-hub.serviceConfig = {
          ExecStartPre = lib.mkForce [
            "${cfg.package}/bin/beszel-hub migrate up"
            "${cfg.package}/bin/beszel-hub migrate history-sync"
          ];
        };
        services.beszel.hub = {
          enable = true;
          package = unstablePkgs.beszel;
          environment = {
            APP_URL = "https://${svcHostname}";
            TRUSTED_AUTH_HEADER = "X-Webauth-User";
            TRUSTED_PROXY_IPS = "127.0.0.1 ::1";
          };
        };
        caddyProxy.status = port;
      };
    pc =
      {
        config,
        unstablePkgs,
        ...
      }:
      {
        sops.secrets.beszel = { };
        services.beszel.agent = {
          package = unstablePkgs.beszel;
          enable = true;
          smartmon.enable = true;
          environmentFile = config.sops.secrets.beszel.path;
        };
      };
  };
}
