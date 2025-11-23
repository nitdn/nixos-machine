{
  flake.modules.nixos.vps =
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
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        (modulesPath + "/profiles/qemu-guest.nix")
      ];
      services.cloud-init = {
        enable = true;
        network.enable = true;
      };
      networking.useNetworkd = true;

      # Firewalls
      networking.nftables.enable = true;
      networking.firewall.allowedTCPPorts = [ 5432 ];

      environment.systemPackages = map lib.lowPrio [
        pkgs.btop
        pkgs.curl
        pkgs.ghostty
        pkgs.gitMinimal
        pkgs.helix
        pkgs.openssl
      ];

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "mydatabase" ];
        settings.ssl = true;
        settings.listen_addresses = lib.mkForce "*";
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
        "tacker.${domain_name}" = {
          enableACME = true;
          addSSL = true;
          locations."/" = {
            root = "/var/www/tacker";
          };
        };
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
        flags = [
          "--accept-flake-config"
        ];
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
      time.timeZone = "Asia/Kolkata";

      users.users.root.openssh.authorizedKeys.keys = [
        # change this to your ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbQpjuFSDUDRO1j6gvxqI+zGsm4nRtXGxRbup8uzR8E ssmvabaa@tjmaxxer"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFAs8o5K95ZQdqZQqXLhRvjfNHfC3RB5a/OLZKcBm7a nix-on-droid@localhost"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcnwk3vUJDAzD4m28LZHUBju3Fb7J613R7FW4RtR4t ssmvabaa@msi-colgate"
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

      system.stateVersion = "24.11";
    };
}
