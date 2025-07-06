{ config, ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
        "processes"
        "logind"
      ];
      disabledCollectors = [ "textfile" ];
    };
  };

  services.prometheus.enable = true;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {
          targets = [
            "localhost:${toString config.services.prometheus.exporters.node.port}"
            "localhost:${toString config.services.blocky.settings.ports.http}"
          ];
        }
      ];
    }
  ];
  services.prometheus.remoteWrite = [
    {
      url = "https://prometheus-prod-43-prod-ap-south-1.grafana.net/api/prom/push";
      basic_auth = {
        username = "2219843";
        password_file = config.sops.secrets."remote_write/password".path;
      };

    }
  ];
  sops.secrets = {
    "remote_write/password" = {
      owner = config.systemd.services.prometheus.serviceConfig.User;
    };
  };
}
