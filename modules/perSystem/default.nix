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
  imports = [
    # Optional: use external flake logic, e.g.
    inputs.flake-parts.flakeModules.modules
    inputs.treefmt-nix.flakeModule
  ];

  debug = true;

  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    let
      buildInputs = [
        pkgs.makeWrapper
        pkgs.libtiff.out
      ];
      scripts = {
        throttle = ''
          systemd-inhibit --what=sleep:shutdown \
          systemd-run --user --scope \
          --property=MemoryMax=4G --property=CPUQuota=50% \
          --property=CPUWeight=500 "$@"'';
        gc = ''
          ${scripts.throttle} nh clean all --keep-since 7d
        '';
        home = ''
          nh os switch .
          nh home switch .
        '';
        license = ''
          reuse annotate --copyright="Nitesh Kumar Debnath <nitkdnath@gmail.com>" \
          --license="GPL-3.0-or-later" "$@"
        '';
        upgrade-elysium = ''
          sudo ${pkgs.efibootmgr}/bin/efibootmgr -o 0001,2001,3001 # Fixes the issue with mangled UEFI
          ${scripts.throttle} nh os switch .
        '';
        fetch = ''
          jj git fetch --remote flake-mirror
          jj rebase -r @ -d update_flake_lock_action@flake-mirror
        '';
        push-ci = ''
          jj squash
          jj git push -c @- --remote flake-mirror
        '';
        push-new = ''
          jj commit
          change_id=$(jj log -r @-  -T "change_id.short()" --no-graph)
          push-ci
          gh pr create --head push-"$change_id" --fill
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
          ${scripts.throttle} nixos-rebuild test --flake . \
          --build-host root@"$remote" \
          --target-host root@"$remote" \
          --option max-jobs 4
        '';
        remote-build = ''
          remote="''${1:-vps01}"
          ${scripts.throttle} nixos-rebuild build --flake . \
          --build-host root@"$remote" \
          --target-host root@"$remote" \
          --option max-jobs 4
        '';
      };
      toPackage = name: text: pkgs.writeShellApplication { inherit name text; };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) meta.unfreeNames;
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.bashInteractive
          pkgs.cloc
          pkgs.dix
          pkgs.hydra-check
          pkgs.jq
          config.packages.jj-wrapped
          pkgs.kdlfmt
          pkgs.meld
          pkgs.sops
          pkgs.nixd
          pkgs.nil
          pkgs.nh
          pkgs.nixfmt
          pkgs.pandoc
          pkgs.reuse
          pkgs.tinymist
          pkgs.typstyle
          pkgs.vscode-langservers-extracted
          (lib.mapAttrsToList toPackage scripts)
        ];
      };
      packages = {
        bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix {
          inherit (inputs) bizhub-225i;
        };
        epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix {
          inherit (inputs) epson-202101w;
        };
        naps2-wrapped = pkgs.naps2.overrideAttrs (
          _finalAttrs: previousAttrs: {
            buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
            postFixup = previousAttrs.postFixup or "" + ''
              chmod +x $out/lib/naps2/_linux/tesseract 
              wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
              ${toString (lib.makeLibraryPath buildInputs)}
            '';
          }
        );
      };
      checks.reuse =
        pkgs.runCommand "reuse"
          {
            src = inputs.self.outPath;
            nativeBuildInputs = [ pkgs.reuse ];
          }
          ''
            cd $src
            reuse lint | tac >&2
            mkdir $out
          '';
      treefmt.programs =
        lib.genAttrs
          [
            "actionlint"
            "deadnix"
            "just"
            "nixfmt"
            "shfmt"
            "sqlfluff-lint"
            "statix"
            "taplo"
            "typstyle"
            "yamlfmt"
            "sqlfluff"
            "typos"
          ]
          (_: {
            enable = true;
          })
        // {
          sqlfluff.dialect = "postgres";
        };
      treefmt.settings.excludes = [
        "**/*.layout.json"
        "secrets/*"
        ".sops.yaml"
        "**/facter.json"
      ];
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
