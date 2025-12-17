{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem =
    {
      inputs',
      pkgs,
      ...
    }:
    {
      overlayAttrs = {
        # inherit (config.legacyPackages) qt6Packages;
      };
      legacyPackages.qt6Packages = pkgs.qt6Packages // {
        inherit (inputs'.stablepkgs.legacyPackages.qt6Packages) fcitx5-qt;
      };
    };
}
