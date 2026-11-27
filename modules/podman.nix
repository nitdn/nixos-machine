# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ lib, config, ... }:
let
  inherit (config.meta) username;
  podman = _: {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };
  };
in
{
  flake.modules.nixos.pc =
    { pkgs, config, ... }:
    {
      imports = [ podman ];
      users.users.${username} = {
        extraGroups = [
          "podman"
        ];
      };
      environment.systemPackages = lib.mkIf config.hardware.graphics.enable [ pkgs.distrobox ];
    };
}
