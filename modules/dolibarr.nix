{
  flake.modules.nixos.vps =
    { config, ... }:
    let
      inherit (config.services.bind) domain_name;
    in
    {
      services.dolibarr = {
        enable = true;
        domain = "erp.${domain_name}";
        nginx = { };
        settings = {
          dolibarr_main_authentication = "openid_connect,dolibarr";
          dolibarr_main_db_collation = "utf8mb4_unicode_ci";
        };
      };
    };
}
