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
      printerConfig.bizhub = {
        location = "shop";
        deviceUri = "usb://KONICA%20MINOLTA/225i?serial=ACN2041204913&interface=1";
        model = "KonicaMinolta/225igdi.ppd";
        ppdOptions = {
          PageSize = "A4";
          Duplexer = "true";
        };

      };
    in
    {
      services = {
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
      hardware = {
        printers.ensurePrinters = [
          (lib.recursiveUpdate printerConfig.bizhub {
            name = "225i-single-sided";
            ppdOptions = {
              Duplex = "None";
            };
          })
          (lib.recursiveUpdate printerConfig.bizhub {
            name = "225i-double-sided";
            ppdOptions = {
              Duplex = "DuplexNoTumble";
              OCM_TonerSave = "TRUE";
            };
          }

          )
        ];
        sane.enable = true;
        sane.openFirewall = true;
        sane.extraBackends = [
          pkgs.sane-airscan
        ];
      };
    };
}
