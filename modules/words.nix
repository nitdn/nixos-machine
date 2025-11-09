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
        # Onlyoffice doesn't like symlinks yet apparently
        installCoreFonts =
          let
            fonts = with pkgs; [
              corefonts
              noto-fonts
              noto-fonts-color-emoji
            ];
          in
          {
            text = ''
              for font in ${builtins.concatStringsSep " " fonts}
              do
                cd $font/share/fonts
                find -type f \
                -exec install --verbose -CDm644 "{}" ~/.local/share/fonts/"{}" \;
              done
            '';
          };
      };
    }
  );
}
