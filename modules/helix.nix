{ inputs, config, ... }:
let
  flakeModules = config.flake.modules;
in
{
  flake.modules.homeManager.helix =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        extraPackages = with pkgs; [
          nixd
          taplo
          yaml-language-server
        ];

        settings = {
          editor = {
            # They are not well implemented anyway
            # end-of-line-diagnostics = "hint";
            # inline-diagnostics.cursor-line = "warning";
            # lsp.display-inlay-hints = true;
          };
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          keys = {
            normal = {
              tab = "move_parent_node_end";
              S-tab = "move_parent_node_start";
            };
            select = {
              tab = "extend_parent_node_end";
              S-tab = "extend_parent_node_start";

            };
          };
        };
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.nixfmt-rfc-style;

          }
          {
            name = "yaml";
            auto-format = true;
            formatter.command = lib.getExe pkgs.dprint;
            formatter.args = [
              "fmt"
              "--stdin"
              "yaml"
            ];
          }
          {
            name = "yuck";
            auto-format = true;
            formatter.command = lib.getExe pkgs.parinfer-rust;
          }
          {
            name = "just";
            # auto-format = true; # This bugs out saving
            language-servers = [ "just-lsp" ];
          }

        ];

        #justfile LSP
        languages.language-server.just-lsp = {
          command = lib.getExe pkgs.just-lsp;
        };
        # YAML config
        languages.language-server.yaml-language-server.config.yaml = {
          format = {
            enable = true;
          };
          validation = true;
        };
      };
      home.sessionVariables.EDITOR = "hx";
    };
  flake.modules.homeManager.pc = {
    imports = [ flakeModules.homeManager.helix ];
    # stylix.targets.helix.enable = false;
  };
  flake.modules.homeManager.droid = {
    imports = [ config.flake.modules.homeManager.helix ];
  };
}
