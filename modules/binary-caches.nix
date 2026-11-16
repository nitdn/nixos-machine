# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  binaryCaches = {
    nix.settings = {
      substituters = [
        "https://machines.cachix.org/"
        "https://nix-community.cachix.org/"
        "https://cache.manic.systems/"
        "https://cache.forall.systems/"
        # This does build oh god
        "https://cache.curlew-rankine.ts.net/"
      ];
      trusted-public-keys = [
        "machines.cachix.org-1:imnXlKFUc4Iaedv6469v6TO37ruiNh6OfJN4le5bqdE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
        "cache.curlew-rankine.ts.net-1:GFW+bWipZGYv99VtugN7KhX7QTOm9qAnxaZYWan+5dk="
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
