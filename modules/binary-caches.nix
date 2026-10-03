# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  binaryCaches = {
    nix.settings = {
      substituters = [
        "https://machines.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.manic.systems"
        "https://cache.forall.systems"
      ];
      trusted-public-keys = [
        "machines.cachix.org-1:imnXlKFUc4Iaedv6469v6TO37ruiNh6OfJN4le5bqdE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
      ];
    };
  };
in
{
  flake.modules.nixos = {
    pc = binaryCaches;
    iso = binaryCaches;
  };
}
