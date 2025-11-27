{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.qt6Packages.qt6ct
        pkgs.adw-gtk3
        pkgs.nwg-look
        pkgs.pywalfox-native
      ];
    };
  flake.modules.homeManager.pc = {
    programs.niri.settings.environment = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
    programs.ghostty.settings.theme = "noctalia";
    programs.noctalia-shell.settings = {
      templates = {
        gtk = true;
        qt = true;
        kcolorscheme = true;
        alacritty = true;
        kitty = true;
        ghostty = true;
        foot = true;
        wezterm = true;
        fuzzel = true;
        discord = true;
        pywalfox = true;
        vicinae = true;
        walker = true;
        code = true;
        spicetify = true;
        cava = true;
        enableUserTemplates = true;
      };
    };
  };
}
