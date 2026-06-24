# Baseline for a kakoune wrapper
{ inputs, config, ... }:

let
  inherit (config.flake) wrappers;
in
{
  flake = {
    modules.nixos.pc = { pkgs, ... }: {
      environment.systemPackages = [
        (wrappers.kakoune-pc.wrap { inherit pkgs; })
      ];
      environment.variables = {
        EDITOR = "kak";
        VISUAL = "kak";
      };
    };
    wrappers.kakoune-pc = {
      imports = [ inputs.nix-devshells.wrapperModules.kakoune ];
    };
  };
}
