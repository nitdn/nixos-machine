{
  lib,
  stdenv,
  fetchurl,
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

  src = fetchurl {
    urls = [
      "https://download3.ebz.epson.net/dsc/f/03/00/15/15/02/f5cba2761f2f501363cdbf7e1b9b9879b0715aa5/epson-inkjet-printer-202101w-1.0.2-1.src.rpm"
    ];
    sha256 = "sha256-n0Ff2wfhPruYhzAH0GrhpYpkddiQ3rkYukvZyRgrn54=";
  };

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
    homepage = "https://www.openprinting.org/driver/epson-202101w";
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
    # We will remove the license declaration because it breaks local builds
    # license = with licenses; [
    #   lgpl21
    #   epson
    # ];
    platforms = platforms.linux;
    # The guy I stole this config from
    # maintainers = [ maintainers.lunarequest ];
  };
}
