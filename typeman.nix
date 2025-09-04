{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  expat,
  fontconfig,
  freetype,
  libGL,
  xorg,
  wayland,
  libxkbcommon,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typeman";
  version = "0.1.2";

  buildInputs = [
    pkg-config
    expat
    fontconfig
    freetype
    freetype.dev
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    wayland
    libxkbcommon

  ];

  src = fetchFromGitHub {
    owner = "mzums";
    repo = finalAttrs.pname;
    rev = "0e5dd3be2a2769f43ad3b0d91cae6763059d7079";
    hash = "sha256-mTYRa+rtBpfpoUJi2SVXSpFWqEFATp6eDXiNhic7I5A=";
  };

  cargoHash = "sha256-xTsTvh5pxA72KcmcPa3mVK5WObB+QhmXO6vueJ851jk=";

  meta = {
    description = "Typing speed test with practice mode in GUI, TUI and CLI";
    homepage = "https://github.com/mzums/typeman";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
