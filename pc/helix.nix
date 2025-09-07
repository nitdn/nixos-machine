{
  self,
  pkgs,
  lib,
  username,
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
      # this has the best contrast imo
      theme = lib.mkDefault "darcula";
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

    # Enables LSP for flake-parts
    languages.language-server.nixd.config.nixd.options.flake-parts = {
      expr = "(builtins.getFlake \"${self.outPath}\").debug.options";
    };
    # Enables LSP for home-manager
    languages.language-server.nixd.config.nixd.options.home-manager = {
      expr = "(builtins.getFlake \"${self.outPath}\").homeConfigurations.\"${username}\".options";
    };

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

}
