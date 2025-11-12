{
  inputs,
  moduleWithSystem,
  config,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.shells = moduleWithSystem (
    {
      pkgs,
      inputs',
      ...
    }:
    {
      config,
      lib,
      ...
    }:
    {
      programs.eza = {
        enable = true;
      };

      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "y";

        settings = {
          manager = {
            show_hidden = true;
          };
          preview = {
            max_width = 1000;
            max_height = 1000;
          };
        };
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = [ inputs'.direnv-instant.packages.default ];

      programs.starship = {
        enable = true;
      };
      home.file."${config.xdg.configHome}/starship.toml".source = lib.mkForce (
        pkgs.fetchurl {
          url = "https://starship.rs/presets/toml/jetpack.toml";
          hash = "sha256-qCN4jI/LuMgyM80J5LZctCSuC8NzPrC+WlruFQUxjF8=";
        }
      );

      programs.fzf = {
        enable = true;
      };
      programs.zoxide = {
        enable = true;
      };
      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batwatch
          batpipe
        ];
      };
      programs.btop.enable = true;
    }
  );
  flake.modules.homeManager = {
    pc.imports = [ homeModules.shells ];
    droid.imports = [ homeModules.shells ];
  };
}
