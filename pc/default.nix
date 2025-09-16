{
  inputs,
  lib,
  config,
  ...
}:
{
  options = {
    pc.username = lib.mkOption {
      type = lib.types.str;
    };
  };
  imports = [
    ./disko-elysium
    ./tjmaxxer
    ./phone-home
  ];
  config.flake.nixosModules = {
    default = {
      imports = [
        ./configuration.nix
        ./stylix.nix
      ];
      programs.niri.enable = true;
      nixpkgs.overlays = [
        inputs.niri.overlays.niri
      ];
    };
  };
  config.flake.homeModules = {
    default = {
      imports = [ ./home.nix ];
      home.username = config.pc.username;
    };
  };
}
