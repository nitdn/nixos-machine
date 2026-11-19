# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
let
  dolibarr = _: {
    services.dolibarr = {
      enable = true;
      settings = {
        dolibarr_main_authentication = "openid_connect,dolibarr";
        dolibarr_main_db_collation = "utf8mb4_unicode_ci";
      };
    };
  };
in
{
  flake.modules.nixos = {
    vps =
      { config, ... }:
      let
        inherit (config.services.bind) domain_name;
      in
      {
        imports = [ dolibarr ];
        services.dolibarr = {
          domain = "erp.${domain_name}";
        };
      };
  };
}
