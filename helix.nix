{
  self,
  pkgs,
  lib,
  username,
  ...
}:
{
  programs.helix = {
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";
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
    ];

    # Enables LSP for flake-parts
    languages.language-server.nixd.config.nixd.options.flake-parts = {
      expr = "(builtins.getFlake \"${self.outPath}\").debug.options";
    };
    # Enables LSP for home-manager
    languages.language-server.nixd.config.nixd.options.home-manager = {
      expr = "(builtins.getFlake \"${self.outPath}\").homeConfigurations.\"${username}\".options";
    };
  };

}
