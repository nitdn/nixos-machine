{ pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    fonts = {
      sansSerif.package = pkgs.atkinson-hyperlegible-next;
      sansSerif.name = "Atkinson Hyperlegible Next";
      monospace.package = pkgs.nerd-fonts.jetbrains-mono;
      monospace.name = "JetBrainsMono Nerd Font";
    };
  };
}
