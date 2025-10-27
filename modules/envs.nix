{ config, moduleWithSystem, ... }:
let
  inherit (config.meta) username;
in

{
  flake.modules.nixos.pc = moduleWithSystem (
    { pkgs, inputs', ... }:
    {
      programs.fish.enable = true;
      programs.bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };
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
        du-dust
        eza
        gamescope
        ghostty
        git
        gparted
        helix
        ldns # drill
        mangohud
        openssl
        pwgen
        ripgrep
        sops
        trashy
        vulkan-tools
        wineWowPackages.stagingFull
        inputs'.noctalia.packages.default
      ];
    }
  );
}
