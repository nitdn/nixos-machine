# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  binaryCaches = {
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org/"
        "https://cache.manic.systems/"
        "https://cache.forall.systems/"
        # This does build oh god
        "https://cache.curlew-rankine.ts.net/attic-1"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
        "attic-1:x1VciK3K4xP1KWLhP6MOJKwyCHPHvLMGctZHKjaR4gQ="
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
