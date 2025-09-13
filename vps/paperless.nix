{ config, ... }:
let
  domain_name = config.services.bind.domain_name;
in
{
  services.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };
  services.nginx.virtualHosts = {
    "paperless.${domain_name}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.paperless.port}";
      };
    };
  };
  services.paperless = {
    enable = true;
    consumptionDirIsPublic = true;
    environmentFile = config.sops.secrets.paperless.path;
    settings = {
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "eng+hin+ben";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://paperless.${config.services.bind.domain_name}";
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
    };
  };
  sops.secrets.paperless = {
    sopsFile = ../secrets/paperless.env;
    format = "dotenv";
    key = "";
  };
}
