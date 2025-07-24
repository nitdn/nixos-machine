{
  stdenv,
  cups,
  autoPatchelfHook,
  fetchzip,
  rpmextract,
}:

stdenv.mkDerivation rec {
  name = "konica-bizhub-225i-${version}";
  version = "2.01-0";
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    cups
  ];

  src = fetchzip {
    url = "https://public.integration.yamayuri.kiku8101.com/publicdownload/download?fileId=B2C0B6D9-C563-4377-B77B-33BBAC4A5EC8#${name}.zip";
    hash = "sha256-urrs4DUFz3KFvX7G0xFLHauijlxNLa2evpPhYzbA8fU=";
  };

  unpackPhase = ''
    ${rpmextract}/bin/rpmextract $src/For_x86_64/konica-minolta-245igdi-cups-${version}.x86_64.rpm
  '';

  installPhase = ''
    runHook preInstall
    cp -r usr/ $out/
    substituteInPlace $out/share/cups/model/KonicaMinolta/225igdi.ppd \
    --replace-fail "/usr/lib/cups/filter/KonicaMinolta/245igdi" \
    $out/lib/cups/filter/KonicaMinolta/245igdi
    runHook postInstall
  '';
}
