# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, ... }:
let
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos.vps =
    { config, ... }:
    let
      inherit (config.services.bind) domain_name;
    in
    {
      imports = [ nixosModules.dolibarr ];
      services.dolibarr = {
        domain = "erp.${domain_name}";
        nginx = { };
      };
    };
  flake.modules.nixos.work =
    { config, ... }:
    {
      imports = [ nixosModules.dolibarr ];
      networking.firewall.allowedTCPPorts = [
        22
        80
        443
      ];
      services.dolibarr = {
        domain = "erp.localhost";
        nginx = {
          serverAliases = [
            "dolibarr.${config.networking.domain}"
            "erp.${config.networking.domain}"
            "dolibarr.${config.networking.hostName}.local"
            "erp.${config.networking.hostName}.local"
          ];
          enableACME = false;
          forceSSL = false;
        };
      };
      services.nginx = {
        enable = true;
        virtualHosts.localhost = {
          serverAliases = [
            "${config.networking.hostName}.local"
          ];
          locations."/" = {
            return = "200 '<html><body>It works</body></html>'";
            extraConfig = ''
              default_type text/html;
            '';
          };
        };
      };
    };

  flake.modules.nixos.dolibarr = {
    services.dolibarr = {
      enable = true;
      settings = {
        dolibarr_main_authentication = "openid_connect,dolibarr";
        dolibarr_main_db_collation = "utf8mb4_unicode_ci";
      };
    };
  };
}
