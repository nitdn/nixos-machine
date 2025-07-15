{
  stdenv,
  cups,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  name = "bizhub-225i-${version}";
  version = "1.0";
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    cups
  ];

  src = ./.;

  installPhase = ''
    runHook preInstall
      cp -r usr/ $out/
      substituteInPlace $out/share/cups/model/KonicaMinolta/225igdi.ppd \
      --replace-warn "/usr/lib/cups/filter/KonicaMinolta/245igdi" \
      $out/lib/cups/filter/KonicaMinolta/245igdi
      runHook postInstall
  '';
}
