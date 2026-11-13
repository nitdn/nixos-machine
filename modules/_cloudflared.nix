# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { config, ... }:
    {
      services.cloudflared = {
        enable = true;
        tunnels = {
          "76111d5c-b72a-4510-a6a7-de6bef0542b1" = {
            credentialsFile = "${config.sops.secrets.cloudflared-creds.path}";
            default = "http_status:404";
          };
        };
      };
      sops.secrets.cloudflared-creds = {
        sopsFile = ../secrets/cloudflared-76111d5c-b72a-4510-a6a7-de6bef0542b1.json;
        format = "json";
        key = "";
      };
    };
}
