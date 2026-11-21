# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
_: {
  flake.modules.nixos.homelab =
    { config, pkgs, ... }:

    {
      # Must contain: GARAGE_RPC_SECRET=<openssl rand -hex 32>
      sops.secrets."garage-env" = {

        restartUnits = [ "garage.service" ];
      };

      services.garage = {
        enable = true;
        package = pkgs.garage_2;
        environmentFile = config.sops.secrets."garage-env".path;

        settings = {
          replication_factor = 1;
          rpc_bind_addr = "127.0.0.1:3901";
          s3_api = {
            s3_region = "garage";
            api_bind_addr = "[::]:3900";
          };
        };
      };
    };
}
