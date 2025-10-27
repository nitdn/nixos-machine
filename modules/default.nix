{
  inputs,
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;

in
{
  options = {
    meta.username = lib.mkOption {
      type = lib.types.str;
    };
    meta.unfreeNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config.flake.modules.nixos = {
    pc = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        nixosModules.base
      ];
      nixpkgs.overlays = [
        config.flake.overlays.default
      ];
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.meta.unfreeNames;
    };
  };
}
