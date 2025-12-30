# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ moduleWithSystem, ... }:
{
  meta.unfreeNames = [
    "konica-bizhub-225i"
    "epson-202101w"
  ];
  flake.modules.nixos.pc = moduleWithSystem (
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config) packages;
    in
    {
      # Enable CUPS to print documents.
      services.printing.enable = true;
      services.system-config-printer.enable = true;
      programs.system-config-printer.enable = true;
      # services.printing.logLevel = "debug";
      services.printing.drivers = [
        packages.bizhub-225i
        packages.epson-l3212
      ];

      hardware.sane.enable = true;
      services.ipp-usb.enable = true;
      hardware.sane.extraBackends = [
        pkgs.sane-airscan
      ];
    }
  );
}
