{
  self,
  inputs,
  withSystem,
  ...
}:
{

  flake.nixOnDroidConfigurations.default = withSystem "aarch64-linux" (
    { pkgs, ... }:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [
        ./nix-on-droid.nix
        # list of extra modules for Nix-on-Droid system
        # { nix.registry.nixpkgs.flake = nixpkgs; }
        # ./path/to/module.nix

        # or import source out-of-tree modules like:
        # flake.nixOnDroidModules.module
      ];

      # list of extra special args for Nix-on-Droid modules
      extraSpecialArgs = {
        inherit self;
        # rootPath = ./.;
      };
      inherit pkgs;
      # set path to home-manager flake
      home-manager-path = inputs.home-manager.outPath;
    }
  );
}
