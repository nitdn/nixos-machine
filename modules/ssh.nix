# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  trusted_ssh_keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbQpjuFSDUDRO1j6gvxqI+zGsm4nRtXGxRbup8uzR8E ssmvabaa@tjmaxxer"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFAs8o5K95ZQdqZQqXLhRvjfNHfC3RB5a/OLZKcBm7a nix-on-droid@localhost"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcnwk3vUJDAzD4m28LZHUBju3Fb7J613R7FW4RtR4t ssmvabaa@msi-colgate"
  ];
  inherit (config.meta) username;
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos = {
    secureSSH = {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [
            username
            "sandbox"
          ];
        };
      };
      services.fail2ban.enable = true;
    };

    pc =
      { pkgs, ... }:
      {
        imports = [ nixosModules.secureSSH ];
        users.users.${username}.openssh.authorizedKeys.keys = trusted_ssh_keys;
        services.avahi.extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      };
    vps = {
      imports = [ nixosModules.secureSSH ];
    };
    iso =
      { pkgs, ... }:
      {
        systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
        users.users.root.openssh.authorizedKeys.keys = trusted_ssh_keys;

      };
  };
}
