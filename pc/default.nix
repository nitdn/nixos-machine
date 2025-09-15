{ lib, ... }:
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
}
