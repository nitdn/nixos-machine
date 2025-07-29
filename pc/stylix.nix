{ pkgs, lib, ... }:
{
  stylix = {
    enable = true;
    polarity = lib.mkDefault "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/darcula.yaml";
    cursor = {
      name = "Adwaita";
      size = 24;
      # package = pkgs.bibata-cursors;
      package = pkgs.adwaita-icon-theme;
    };
    fonts = {
      sansSerif.package = pkgs.atkinson-hyperlegible-next;
      sansSerif.name = "Atkinson Hyperlegible Next";
      monospace.package = pkgs.nerd-fonts.jetbrains-mono;
      monospace.name = "JetBrainsMono Nerd Font";
      sizes = {
        popups = 18;
      };
    };
  };
}
