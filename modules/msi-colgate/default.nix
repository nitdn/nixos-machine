# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  config,
  inputs,
  moduleWithSystem,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
  inherit (config.flake.modules) generic;
in
{
  flake.modules.homeManager.light = {
    imports = [ config.flake.modules.generic.light ];
    programs.helix.settings.theme = "ayu_light";
  };

  flake.modules.generic.light = _: {
    # stylix.polarity = "light";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-light.yaml";
  };

  flake.modules.nixos.msi-colgate = moduleWithSystem (
    { ... }:
    {
      imports = [
        generic.light
      ];
      networking.useDHCP = true;
      hardware.facter.reportPath = ./facter.json;
      networking.hostName = "msi-colgate"; # Define your hostname.
    }
  );

  flake.nixosConfigurations.msi-colgate = inputs.nixpkgs.lib.nixosSystem {
    modules = lib.attrValues {
      inherit (nixosModules)
        pc
        work
        msi-colgate
        hmBase
        ;
    };
  };
}
