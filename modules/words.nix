{ moduleWithSystem, ... }:
{
  meta.unfreeNames = [
    "corefonts"
  ];
  flake.modules.nixos.pc = moduleWithSystem (
    { inputs', ... }:
    {
      pkgs,
      lib,
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
        (
          let
            item = {
              name = "affinity-fix";
              desktopName = "Affinity (workaround for plugin loader)";
              icon = "affinity-v3";
              exec = item.name;
            };
          in
          makeDesktopItem item
        )
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
        fcitx5.addons = with pkgs; [
          catppuccin-fcitx5
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
