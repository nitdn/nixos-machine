{
  inputs,
  lib,
  flake-parts-lib,
  moduleWithSystem,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    options.niri = {
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        example = ''
          input {
            mouse {
              accel-speed -0.7
              accel-profile flat
            }
          }
        '';
        description = "Niri configuration in lines, must close all brackets";
      };
    };
  };
  config.perSystem =
    { pkgs, config, ... }:
    {
      niri.extraConfig = lib.readFile ./niri.kdl;
      packages.niri-wrapped =
        (inputs.wrappers.wrapperModules.niri.apply {
          inherit pkgs;
          "config.kdl".content = config.niri.extraConfig;
        }).wrapper;
    };
  config.flake.modules.nixos.pc = moduleWithSystem (
    { config, pkgs, ... }:
    {
      config = {
        programs.niri.enable = true;
        programs.niri.package = config.packages.niri-wrapped;
        environment.systemPackages = [
          pkgs.wl-clipboard
          pkgs.cliphist
          pkgs.xwayland-satellite
        ];
      };
    }
  );
}
