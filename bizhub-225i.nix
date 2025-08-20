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
    url = "https://dl.konicaminolta.eu/en/?tx_kmdownloadproxy_downloadproxy[fileId]=4562fe1cc1a8e069fd2f57714fd11d89&tx_kmdownloadproxy_downloadproxy[documentId]=138755&tx_kmdownloadproxy_downloadproxy[system]=KonicaMinolta&tx_kmdownloadproxy_downloadproxy[language]=EN&type=1558521685#${name}.zip";
    hash = "sha256-urrs4DUFz3KFvX7G0xFLHauijlxNLa2evpPhYzbA8fU=";
  };

  unpackPhase = ''
    ${rpmextract}/bin/rpmextract $src/For_x86_64/konica-minolta-245igdi-cups-${version}.x86_64.rpm
  '';

  installPhase = ''
    runHook preInstall
    cp -r usr/ $out/
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
}
