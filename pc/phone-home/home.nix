{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../helix.nix
    ../gitui.nix
  ];

  home.file = {
    "${config.xdg.configHome}/starship.toml".source = lib.mkForce (
      pkgs.fetchurl {
        url = "https://starship.rs/presets/toml/jetpack.toml";
        hash = "sha256-qCN4jI/LuMgyM80J5LZctCSuC8NzPrC+WlruFQUxjF8=";
      }
    );
  };

  programs.starship = {
    enable = true;
  };

  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Read the changelog before changing this value
  home.stateVersion = "24.05";

  # insert home-manager config
}
