{
  lib,
  stdenv,
  cups,
  autoPatchelfHook,
  fetchzip,
  rpmextract,
}:
let
  cpu = stdenv.hostPlatform.linuxArch;
in

stdenv.mkDerivation rec {
  pname = "konica-bizhub-225i";
  version = "2.0.1";
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    cups
  ];

  src = fetchzip {
    url = "https://public.integration.yamayuri.kiku8101.com/publicdownload/download?fileId=B2C0B6D9-C563-4377-B77B-33BBAC4A5EC8#${pname}-${version}.zip";
    hash = "sha256-urrs4DUFz3KFvX7G0xFLHauijlxNLa2evpPhYzbA8fU=";
  };

  unpackPhase = ''
    ${rpmextract}/bin/rpmextract $src/For_${cpu}/konica-minolta-245igdi-cups-2.01-0.${cpu}.rpm
  '';

  installPhase = ''
    runHook preInstall
    cp -a usr/ $out/
    cp -a $src/Readme/ $out/doc/
    substituteInPlace $out/share/cups/model/KonicaMinolta/205igdi.ppd \
    --replace-fail "/usr/lib/cups/filter/KonicaMinolta/245igdi" \
    $out/lib/cups/filter/KonicaMinolta/245igdi
    substituteInPlace $out/share/cups/model/KonicaMinolta/225igdi.ppd \
    --replace-fail "/usr/lib/cups/filter/KonicaMinolta/245igdi" \
    $out/lib/cups/filter/KonicaMinolta/245igdi
    substituteInPlace $out/share/cups/model/KonicaMinolta/245igdi.ppd \
    --replace-fail "/usr/lib/cups/filter/KonicaMinolta/245igdi" \
    $out/lib/cups/filter/KonicaMinolta/245igdi
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
