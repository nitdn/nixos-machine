{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.services.bind) domain_name;
in
{

  nix.settings.substituters = [
    "https://cache.garnix.io"
  ];
  nix.settings.trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./bind.nix
    ./blocky.nix
    ./failing2ban.nix
    ./prometheus.nix
    ./paperless.nix
  ];
  # cleanup configs

  services.bind = {
    domain_name = "slipstr.click";
    IPv4 = "147.93.97.244";
    IPv6 = "2a02:4780:12:d0d9::1";
  };

  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  networking.useNetworkd = true;

  # Firewalls
  networking.nftables.enable = true;
  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mydatabase" ];
    settings.ssl = true;
    settings.listen_addresses = lib.mkForce "*";
    initialScript = config.sops.secrets.blocky_initdb.path;
    identMap = ''
      # ArbitraryMapName systemUser DBUser
         superuser_map      root      postgres
         superuser_map      postgres  postgres
         # Let other names login as themselves
         superuser_map      /^(.*)$   \1
    '';
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method   optional_ident_map
      local sameuser  all     peer          map=superuser_map
      host  sameuser  all     127.0.0.1/32  scram-sha-256
      host  sameuser  all     ::1/128       scram-sha-256
      host  sameuser  blocky  all           scram-sha-256
    '';
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      server.port = 8001;
      server.bind_address = "::1";
      server.secret_key = config.sops.secrets.searx.path;

    };
  };

  services.dolibarr = {
    enable = true;
    domain = "erp.${domain_name}";
    nginx = { };
    settings = {
      dolibarr_main_authentication = "openid_connect,dolibarr";
      dolibarr_main_db_collation = "utf8mb4_unicode_ci";
    };
  };

  services.authentik = {
    # other authentik options as in the example configuration at the top
    enable = true;
    # The environmentFile needs to be on the target host!
    # Best use something like sops-nix or agenix to manage it
    environmentFile = config.sops.secrets.authentik-env.path;
    settings = {
      disable_startup_analytics = true;
      avatars = "initials";
    };
    nginx = {
      enable = true;
      enableACME = true;
      host = "auth.${domain_name}";
    };
  };

  sops.secrets.authentik-env = {
    sopsFile = ../secrets/authentik.env;
    format = "dotenv";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "search.${domain_name}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8001";
      };
    };
    "dns.${domain_name}" = {
      forceSSL = true;
      enableACME = true;
      locations."/dns-query" = {
        proxyPass = "http://localhost:4000";
      };
      locations."/" = {
        basicAuthFile = ../secrets/blocky-htpasswd;
        proxyPass = "http://localhost:4000";
      };
    };
  };

  sops.secrets.blocky_initdb = {
    owner = config.systemd.services.postgresql.serviceConfig.User;
    sopsFile = ../secrets/postgres-secrets.yaml;
  };

  sops.secrets.pgtls-crt = {
    format = "binary";
    owner = config.systemd.services.postgresql.serviceConfig.User;
    sopsFile = ../secrets/postgres-server.crt;
    path = "${config.services.postgresql.dataDir}/server.crt";
  };
  sops.secrets.pgtls-key = {
    format = "binary";
    owner = config.systemd.services.postgresql.serviceConfig.User;
    sopsFile = ../secrets/postgres-server.key;
    path = "${config.services.postgresql.dataDir}/server.key";
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "git+https://codeberg.org/nitdn/nixos-machine.git";
    allowReboot = true;
  };
  networking.hostName = "vps01";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  programs.fish.enable = true;
  time.timeZone = "Asia/Kolkata";

  environment.systemPackages = map lib.lowPrio [
    pkgs.btop
    pkgs.curl
    pkgs.ghostty
    pkgs.gitMinimal
    pkgs.helix
    pkgs.openssl
  ];

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbQpjuFSDUDRO1j6gvxqI+zGsm4nRtXGxRbup8uzR8E ssmvabaa@tjmaxxer"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGci+FnnDA7n5t/UQIOzpOEJtOpNEZN2sxHVxp+As/l+ nix-on-droid@localhost"
  ];

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../secrets/core.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  sops.secrets = {
    searx = { };
  };

  system.stateVersion = "24.11";
}
