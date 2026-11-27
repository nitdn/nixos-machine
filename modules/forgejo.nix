# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos.homelab =
    { config, lib, ... }:
    let
      cfg = config.services.forgejo;
      srv = cfg.settings.server;
      basename = "curlew-rankine.ts.net";
    in
    {
      services.forgejo = {
        enable = true;
        database = {
          type = "postgres";
        };
        settings = {
          server = {
            DOMAIN = "git.${basename}";
            ROOT_URL = "https://${srv.DOMAIN}";
            HTTP_PORT = 3000;
            SSH_PORT = lib.lists.head config.services.openssh.ports;
          };
          service = {
            DISABLE_REGISTRATION = true;
          };
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };
        };
      };
    };
}
