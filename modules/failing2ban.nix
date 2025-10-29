{
  flake.modules.nixos.vps = {
    services.fail2ban = {
      enable = true;
    };
  };
}
