{
  lib,
  inputs,
  config,
  ...
}:
{
  debug = true;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  imports = [
    # Optional: use external flake logic, e.g.
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
    inputs.treefmt-nix.flakeModule
  ];
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      buildInputs = [
        pkgs.makeWrapper
        pkgs.libtiff.out
      ];
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.meta.unfreeNames;
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };
      # pkgsDirectory = ../../pkgs;
      packages =
        lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ../../pkgs;
        }
        // {
          naps2-wrapped = pkgs.naps2.overrideAttrs (
            finalAttrs: previousAttrs: {
              buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
              postFixup = previousAttrs.postFixup or "" + ''
                chmod +x $out/lib/naps2/_linux/tesseract 
                wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
                ${builtins.toString (pkgs.lib.makeLibraryPath buildInputs)}
              '';
            }
          );
        };

      treefmt.programs = {
        dprint.enable = true;
        nixfmt.enable = true;
        just.enable = true;
        shfmt.enable = true;
        sqlfluff.enable = true;
        sqlfluff.dialect = "postgres";
        typstyle.enable = true;
      };
      treefmt.programs.dprint.excludes = [
        "**/*.layout.json"
        "secrets/*"
        ".envrc"
      ];
      treefmt.programs.dprint.settings.plugins = (
        pkgs.dprint-plugins.getPluginList (
          plugins: with plugins; [
            dprint-plugin-json
            dprint-plugin-markdown
            dprint-plugin-toml
            g-plane-pretty_yaml
          ]
        )
      );

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          vscode-langservers-extracted
          eww
          meld
          nixfmt-rfc-style
          nixd
          tinymist
          typstyle
          pandoc
          dix
          cloc
          jq
        ];
      };
    };
}
