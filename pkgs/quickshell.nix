# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ pkgs }:
let
  inherit (pkgs) callPackage;
  sourcesJson = builtins.fromJSON (builtins.readFile ../_sources/generated.json);
  inherit (sourcesJson) quickshell;
  src = fetchTarball {
    url = "${quickshell.src.url}/archive/${quickshell.src.rev}.tar.gz";
    inherit (quickshell.src) sha256;
  };
in
callPackage src { }
