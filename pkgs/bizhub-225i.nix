# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  stdenv,
  cups,
  autoPatchelfHook,
  pname,
  version,
  src,
  rpmextract,
  unzip,
}:
let
  cpu = stdenv.hostPlatform.linuxArch;
in

stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    unzip
    rpmextract
    autoPatchelfHook
  ];
  buildInputs = [
    cups
  ];

  buildPhase = ''
    rpmextract For_${cpu}/konica-minolta-245igdi-cups-2.01-0.${cpu}.rpm
     for ppd in usr/share/cups/model/KonicaMinolta/*; do
       substituteInPlace $ppd --replace-fail "/usr" $out
     done
  '';

  installPhase = ''
    runHook preInstall
    ls .
    cp -a usr/ $out/
    cp -a Readme/ $out/doc/
    runHook postInstall
  '';
  meta =
    let
      inherit (lib) licenses intersectLists platforms;
    in
    {
      homepage = "https://www.btapac.konicaminolta.com/index.html";
      description = "KONICA MINOLTA bizhub 205i/225i/245i Linux Printer Driver";
      longDescription = ''
        This is the GDI driver (CUPS) for KONICA MINOLTA bizhub 225i.


        To use the driver adjust your configuration.nix file:
          services.printing = {
            enable = true;
            drivers = [ pkgs.konica-bizhub-225i ];
          };
      '';
      license = [
        licenses.unfree
      ];
      platforms = intersectLists platforms.linux platforms.x86_64;

    };
}
