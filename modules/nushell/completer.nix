# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, ... }: {
  flake.modules.nixos.pc = { config, ... }: {
    imports = [ inputs.inshellah.nixosModules.default ];
    programs.inshellah.enable = true;
    programs.inshellah.nushellPackage = config.wrappers.nushell-pc.wrapper;
  };
}
