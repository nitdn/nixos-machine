let
  leader.key = "alt+space";
in
{
  flake.modules.homeManager.pc =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.fish.enable = true;
      programs.fish.shellAbbrs = {
        gco = "git checkout";
        npu = "nix-prefetch-url";
        rm = "y";
      };
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

      programs.git = {
        enable = true;
        settings = {
          user.name = "John Doe";
          user.email = "johndoe@example.com";
        };
      };

      programs.ghostty = {
        enable = true;
        # settings.window-decoration = "server";
        # settings.font-family = [ "Noto Sans Bengali" ];
        settings.keybind = [
          # "ctrl+h=goto_split:left"
          # "ctrl+l=goto_split:right"
          # "ctrl+j=goto_split:down"
          # "ctrl+k=goto_split:up"
          "${leader.key}>backslash=new_window"
          # "${leader.key}>minus=new_split:down"
          "${leader.key}>shift+backslash=new_window"
          # "${leader.key}>ctrl+minus=new_split:down"
        ];
      };
      home.sessionVariables.TERMINAL = "ghostty";

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
    };
}
