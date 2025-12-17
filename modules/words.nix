{ moduleWithSystem, config, ... }:
let
  user = config.meta.username;
in
{
  meta.unfreeNames = [
    "corefonts"
  ];
  flake.modules.nixos.pc = moduleWithSystem (
    { inputs', ... }:
    let
      stablepkgs = inputs'.stablepkgs.legacyPackages;
    in
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        onlyoffice-desktopeditors
        libreoffice-qt6-fresh
        hunspell
        hunspellDicts.en-gb-large
        inputs'.affinity-nix.packages.v3
        (writeShellApplication {
          name = "affinity-fix";
          runtimeInputs = [ inputs'.affinity-nix.packages.v3 ];
          text = ''
            affinity-v3 wine "$HOME/.local/share/affinity-v3/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
          '';
        })
      ];
      i18n.inputMethod = {
        enable = true;
        # type = "ibus";
        # ibus.engines = with pkgs.ibus-engines; [
        #   typing-booster
        #   openbangla-keyboard
        # ];

        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = with stablepkgs; [
          fcitx5-catppuccin
          fcitx5-gtk
          fcitx5-openbangla-keyboard
        ];
      };
      fonts.packages = with pkgs; [
        corefonts
      ];
      systemd.user.tmpfiles.rules =
        lib.lists.forEach
          [
            pkgs.corefonts
            pkgs.noto-fonts
            pkgs.noto-fonts-color-emoji
          ]
          (pkg: ''
            C+ %h/.local/share/fonts/${pkg.pname} 0755 - - - ${pkg}/share/fonts/
            z %h/.local/share/fonts/${pkg.pname}/* 0755 - - -
          '');
    }
  );
}
