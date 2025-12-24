{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem = _: {
    overlayAttrs = {
      # inherit (config.legacyPackages) qt6Packages;
    };
  };
}
