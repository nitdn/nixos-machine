# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  timezone = {
    time.timeZone = "Asia/Kolkata";
  };
in
{
  flake.modules.nixos = {
    pc = timezone;
    vps = timezone;
  };
}
