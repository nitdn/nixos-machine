{ lib, config, ... }:
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
  config.flake.homeModules = {
    default = {
      imports = [ ./home.nix ];
      home.username = config.pc.username;
    };
  };
}
