# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  nixCore = {
    nix.optimise.automatic = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
in
{
  flake.modules.nixos = {
    pc = nixCore;
    vps = nixCore;
  };
}
