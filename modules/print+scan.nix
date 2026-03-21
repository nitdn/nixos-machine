# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, lib, ... }:
let
  inherit (config.flake) packages;
in
{
  flake.modules.nixos.pc =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (packages.${system})
        bizhub-225i
        epson-l3212
        ;
    in
    {
      services = lib.mkIf config.hardware.graphics.enable {
        # Enable CUPS to print documents.
        printing.enable = true;
        system-config-printer.enable = true;
        # services.printing.logLevel = "debug";
        printing.drivers = [
          bizhub-225i
          epson-l3212
        ];
        ipp-usb.enable = true;
      };
      programs = lib.mkIf config.services.printing.enable {
        system-config-printer.enable = true;
      };
      hardware = lib.mkIf config.hardware.graphics.enable {
        sane.enable = true;
        sane.openFirewall = true;
        sane.extraBackends = [
          pkgs.sane-airscan
        ];
      };
    };
}
