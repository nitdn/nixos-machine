{ moduleWithSystem, ... }:
{
  meta.unfreeNames = [
    "corefonts"
  ];
  flake.modules.nixos.pc = moduleWithSystem (
    { inputs', ... }:
    let
      stablepkgs = inputs'.stablepkgs.legacyPackages;
    in
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        onlyoffice-bin
        libreoffice-qt6-fresh
        hunspell
        hunspellDicts.en-gb-large
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
      system.userActivationScripts = {
        installCoreFonts = {
          text = ''
            mkdir -p ~/.local/share/fonts
            for font in ${
              with pkgs;
              builtins.concatStringsSep " " [
                corefonts
                noto-fonts-extra
                noto-fonts-emoji
              ]
            }
              do cp -rf $font/share/fonts/*/* ~/.local/share/fonts/
              chmod 755 ~/.local/share/fonts/*
            done
          '';
        };
      };
    }
  );
}
