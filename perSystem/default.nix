{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
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
        # Learned this cool trick from flake-parts templates lol
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            # Only add packages built here
            "epson-202101w"
            "konica-bizhub-225i"
          ];
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };
      # packages.typeman = inputs'.typeman.packages.default;
      packages.epson-l3212 = pkgs.callPackage ./epson-l3212.nix { };
      packages.bizhub-225i-ppds = pkgs.callPackage ./bizhub-225i.nix { };
      packages.naps2-wrapped = pkgs.naps2.overrideAttrs (
        finalAttrs: previousAttrs: {
          buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
          postFixup = previousAttrs.postFixup or "" + ''
            chmod +x $out/lib/naps2/_linux/tesseract 
            wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
            ${builtins.toString (pkgs.lib.makeLibraryPath buildInputs)}
          '';
        }
      );
      treefmt.programs = {
        dprint.enable = true;
        nixfmt.enable = true;
        just.enable = true;
        sqlfluff.enable = true;
        sqlfluff.dialect = "postgres";
      };
      treefmt.programs.dprint.excludes = [
        "**/*-lock.json"
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
        ];
      };
    };
}
