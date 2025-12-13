{
  lib,
  stdenv,
  cups,
  autoPatchelfHook,
  bizhub-225i,
  rpmextract,
}:
let
  cpu = stdenv.hostPlatform.linuxArch;
in

stdenv.mkDerivation {
  pname = "konica-bizhub-225i";
  version = "2.0.1";
  nativeBuildInputs = [
    rpmextract
    autoPatchelfHook
  ];
  buildInputs = [
    cups
  ];

  src = bizhub-225i;

  unpackPhase = ''
    rpmextract $src/For_${cpu}/konica-minolta-245igdi-cups-2.01-0.${cpu}.rpm
    for ppd in usr/share/cups/model/KonicaMinolta/*; do
      substituteInPlace $ppd --replace-fail "/usr" $out
      substituteInPlace $ppd --replace "/cups/lib" "/lib/cups"
    done
  '';

  installPhase = ''
    runHook preInstall
    cp -a usr/ $out/
    cp -a $src/Readme/ $out/doc/
    runHook postInstall
  '';
  meta = with lib; {
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
    license = with licenses; [
      unfree
    ];
    platforms = intersectLists platforms.linux platforms.x86_64;

  };
}
