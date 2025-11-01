{
  inputs,
  lib,
  config,
  ...
}:
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
        inputs.nixos-facter-modules.nixosModules.facter
      ];
      nixpkgs.overlays = [
        config.flake.overlays.default
      ];
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.meta.unfreeNames;
    };
    vps = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.authentik-nix.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
      ];
    };
  };
}
