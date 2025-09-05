{
  lib,
  fetchFromGitHub,
  rustPlatform,
  fetchCrate,
  pkg-config,
  makeWrapper,
  expat,
  fontconfig,
  freetype,
  libGL,
  copyDesktopItems,
  makeDesktopItem,
  xorg,
  wayland,
  libxkbcommon,
  pipewire,
  alsa-lib,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typeman";
  stylizedName = "TypeMan";
  version = "0.1.2";

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
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
    pipewire

  ];

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-KDAx0a97mQQcQjd/rTLh3hJ8wElDwAiM40K3ty9+WoI=";
  };

  cargoHash = "sha256-xTsTvh5pxA72KcmcPa3mVK5WObB+QhmXO6vueJ851jk=";

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = finalAttrs.stylizedName;
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.pname} --gui";
    })

    (makeDesktopItem {
      name = "${finalAttrs.pname}-cli";
      desktopName = "${finalAttrs.stylizedName} CLI";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.pname}";
      terminal = true;
    })

  ];

  postInstall = ''
    # The Space between LD_LIBRARY_PATH and : is very important
    wrapProgram $out/bin/${finalAttrs.pname} --prefix LD_LIBRARY_PATH : \
    ${builtins.toString (lib.makeLibraryPath finalAttrs.buildInputs)}
  '';

  meta = {
    description = "Typing speed test with practice mode in GUI, TUI and CLI";
    homepage = "https://github.com/mzums/typeman";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
