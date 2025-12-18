{
  flake.modules.nixos.vps = {
    services.netbird.enable = true;
  };
  flake.modules.nixos.pc = {
    services.netbird.enable = true;
    services.netbird.ui.enable = true;
  };
}
