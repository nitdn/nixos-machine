# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (config) meta;
in
{
  debug = true;

  imports = [
    # Optional: use external flake logic, e.g.
    inputs.flake-parts.flakeModules.modules
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
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) meta.unfreeNames;
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };

      devShells.default = pkgs.mkShell {
        packages =
          with pkgs;
          let
            scripts = {
              gc = ''
                nh clean all --keep-since 7d
                nh clean user --keep-since 7d
              '';
              home = ''
                nh os switch .
                nh home switch .
                gc
              '';
              license = ''
                reuse annotate --copyright="Nitesh Kumar Debnath <nitkdnath@gmail.com>" \
                --license="GPL-3.0-or-later" "$@"
              '';
              upgrade = ''
                nh os switch .
                gc
              '';
              upgrade-elysium = ''
                sudo ${pkgs.efibootmgr}/bin/efibootmgr -o 0001,2001,3001 # Fixes the issue with mangled UEFI
                upgrade
              '';
              fetch = ''
                jj git fetch --remote flake-mirror
                jj rebase -r @ -d update_flake_lock_action@flake-mirror
              '';
              push-ci = ''
                nix flake check
                jj squash
                jj git push -c @- --remote flake-mirror
              '';
              push-new = ''
                jj desc && jj new
                push-ci
              '';
              push-main = ''
                jj bookmark set -r @- main
                jj git push -r @- --remote flake-mirror --bookmark main
                jj git push -r @- --remote origin
              '';
              pwget = ''
                sops decrypt --extract "['$1']['password']" secrets/core.yaml
              '';
              remote-test = ''
                remote="''${1:-vps01}"
                nixos-rebuild test --flake . \
                --build-host root@"$remote" \
                --target-host root@"$remote" \
                --option max-jobs 4
              '';
              remote-build = ''
                remote="''${1:-vps01}"
                nixos-rebuild build --flake . \
                --build-host root@"$remote" \
                --target-host root@"$remote" \
                --option max-jobs 4
              '';
            };
            toPackage = name: text: pkgs.writeShellApplication { inherit name text; };
          in
          [
            cloc
            dix
            hydra-check
            jq
            jujutsu
            kdlfmt
            meld
            sops
            nixd
            nil
            nh
            nixfmt
            pandoc
            reuse
            tinymist
            typstyle
            vscode-langservers-extracted
            (lib.mapAttrsToList toPackage scripts)
          ];
      };

      packages.bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix {
        inherit (inputs) bizhub-225i;
      };
      packages.epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix {
        inherit (inputs) epson-202101w;
      };
      packages.naps2-wrapped = pkgs.naps2.overrideAttrs (
        _finalAttrs: previousAttrs: {
          buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
          postFixup = previousAttrs.postFixup or "" + ''
            chmod +x $out/lib/naps2/_linux/tesseract 
            wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
            ${toString (pkgs.lib.makeLibraryPath buildInputs)}
          '';
        }
      );
      checks.reuse =
        pkgs.runCommand "reuse"
          {
            src = inputs.self.outPath;
            nativeBuildInputs = [ pkgs.reuse ];
          }
          ''
            cd $src
            reuse lint 
            mkdir $out
          '';

      treefmt.programs = {
        just.enable = true;
        nixfmt.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        shfmt.enable = true;
        sql-formatter.dialect = "postgresql";
        sql-formatter.enable = true;
        taplo.enable = true;
        typstyle.enable = true;
        typos.enable = true;
        yamlfmt.enable = true;
      };
      treefmt.settings.excludes = [
        "**/*.layout.json"
        "secrets/*"
        ".sops.yaml"
        "**/facter.json"
      ];
      treefmt.programs.typos.excludes = [
      ];
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
