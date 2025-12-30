# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  stdenv,
  epson-202101w,
  rpmextract,
  autoreconfHook,
  file,
  libjpeg,
  cups,
}:

let
  version = "1.0.2";
  filterVersion = "1.0.2";
in
stdenv.mkDerivation {
  pname = "epson-202101w";
  inherit version;

  src = epson-202101w;

  nativeBuildInputs = [
    rpmextract
    autoreconfHook
    file
  ];

  buildInputs = [
    libjpeg
    cups
  ];

  unpackPhase = ''
    rpmextract $src
    tar -zxf epson-inkjet-printer-202101w-${version}.tar.gz
    tar -zxf epson-inkjet-printer-filter-${filterVersion}.tar.gz
    for ppd in epson-inkjet-printer-202101w-${version}/ppds/*; do
      substituteInPlace $ppd --replace "/opt/epson-inkjet-printer-202101w" "$out"
      substituteInPlace $ppd --replace "/cups/lib" "/lib/cups"
    done
    cd epson-inkjet-printer-filter-${filterVersion}
  '';

  preConfigure = ''
    chmod +x configure
  '';

  postInstall = ''
    cd ../epson-inkjet-printer-202101w-${version}
    cp -a lib64 resource watermark $out
    mkdir -p $out/share/cups/model/epson-inkjet-printer-202101w
    cp -a ppds $out/share/cups/model/epson-inkjet-printer-202101w/
    cp -a Manual.txt $out/doc/
    cp -a README $out/doc/README.driver
  '';

  meta = with lib; {
    homepage = "http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX";
    description = "Epson printer driver (L3210 L3200 L1250 L1210)";
    longDescription = ''
      This software is a filter program used with the Common UNIX Printing
      System (CUPS) under Linux. It supplies high quality printing with
      Seiko Epson Color Ink Jet Printers.

      To use the driver adjust your configuration.nix file:
        services.printing = {
          enable = true;
          drivers = [ pkgs.epson-202101w ];
        };
    '';
    license = with licenses; [
      lgpl21
      epson
    ];
    platforms = platforms.linux;
    # The guy I stole this config from
    maintainers = [ maintainers.lunarequest ];
  };
}
