# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  flakeModules = config.flake.modules;
in
{
  flake.modules.generic.fish =
    { pkgs, ... }:
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
    };
  flake.modules.homeManager.fish = _: {
    programs.fish.enable = true;
    programs.fish.shellAbbrs = {
      gco = "git checkout";
      npu = "nix-prefetch-url";
      rm = "y";
    };
  };
  flake.modules.nixos = {
    pc.imports = [ flakeModules.generic.fish ];
    vps.imports = [ flakeModules.generic.fish ];
    droid =
      {
        pkgs,
        ...
      }:
      {
        user.shell = "${pkgs.fish}/bin/fish";
      };
  };
  flake.modules.homeManager = {
    pc =
      { pkgs, ... }:
      {
        imports = with flakeModules; [
          homeManager.fish
        ];
        programs.bash = {
          initExtra = ''
            if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
            then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
          '';
        };
      };
    droid.imports = with flakeModules; [
      homeManager.fish
    ];
  };
}
