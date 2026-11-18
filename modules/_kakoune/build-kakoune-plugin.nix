# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  stdenv,
  rtpPath ? "share/kak/autoload/plugins",
}:
rec {
  buildKakounePlugin =
    attrs@{
      name ? "${attrs.pname}-${attrs.version}",
      namePrefix ? "kakplugin-",
      path ? lib.getName name,
      ...
    }:
    stdenv.mkDerivation (
      (removeAttrs attrs [
        "namePrefix"
        "path"
      ])
      // {
        name = namePrefix + name;

        installPhase = ''
          runHook preInstall

          target=$out/${rtpPath}/${path}
          mkdir -p $out/${rtpPath}
          cp -r . $target

          runHook postInstall
        '';
      }
    );

  buildKakounePluginFrom2Nix =
    attrs:
    buildKakounePlugin (
      {
        dontBuild = true;
        dontConfigure = true;
      }
      // attrs
    );
}
