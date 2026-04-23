# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# This enables per-device separation of light-mode programs
# Since packages can not be overridden at the module level
{ config, ... }:
let
  inherit (config.flake.modules.nixos) darkMode lightMode;
in
{
  flake.modules.nixos = {
    tjmaxxer.imports = [ darkMode ];
    disko-elysium.imports = [ darkMode ];
    msi-colgate.imports = [ lightMode ];
  };
}
