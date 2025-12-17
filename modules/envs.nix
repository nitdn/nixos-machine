{ config, moduleWithSystem, ... }:
let
  inherit (config.meta) username;
in

{
  flake.modules.nixos.pc = moduleWithSystem (
    { pkgs, ... }:
    {
      # docker compat stuff
      environment.etc = {
        "subuid" = {
          mode = "0644";
          text = ''
            ${username}:524288:65536
          '';
        };
        "subgid" = {
          mode = "0644";
          text = ''
            ${username}:524288:65536
          '';
        };
      };
      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #  wget
        adwaita-icon-theme
        bat
        dust
        eza
        ghostty
        git
        gparted
        ldns # drill
        openssl
        pwgen
        ripgrep
        sops
        trashy
        vulkan-tools
        wineWowPackages.stagingFull
      ];
    }
  );
}
