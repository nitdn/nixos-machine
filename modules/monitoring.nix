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
    homelab = _: {
      services.beszel.hub = {
        enable = true;
        environment = {
          APP_URL = "https://${svcHostname}";
          TRUSTED_AUTH_HEADER = "Tailscale-User-Login";
          TRUSTED_PROXY_IPS = "127.0.0.1";
        };
      };
    };
    pc =
      {
        config,

        ...
      }:
      {
        sops.secrets.beszel = { };
        services.beszel.agent = {
          # TODO: 26.11 has support for intel gpus
          enable = true;
          smartmon.enable = true;
          environmentFile = config.sops.secrets.beszel.path;
        };
      };
  };
}
