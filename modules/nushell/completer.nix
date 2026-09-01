# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, config, ... }: {
  flake.modules.nixos.pc = { pkgs, ... }: {
    imports = [ inputs.inshellah.nixosModules.default ];
    programs.inshellah.enable = true;
    programs.inshellah.nushellPackage = config.flake.wrappers.nushell-pc.wrap { inherit pkgs; };
  };
}
