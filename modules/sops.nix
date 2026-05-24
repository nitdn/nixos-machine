# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, ... }:
let
  sopsBase = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # This will add secrets.yml to the nix store. Use a string with the full
    # path instead if the file should stay out of the store.
    sops.defaultSopsFile = ../secrets/core.yaml;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = true;
  };
in
{
  flake.modules.nixos = {
    pc = sopsBase;
    vps = {
      imports = [
        sopsBase
      ];

      # This will automatically import SSH keys as age keys.
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

  };
}
