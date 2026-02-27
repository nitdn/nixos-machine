# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Basically our goal is something like wrappers.kitty.default = submoudle
{
  inputs,
  lib,
  flake-parts-lib,
  ...
}:
{

  options.perSystem = flake-parts-lib.mkPerSystemOption (
    _:
    let
      modules = [
        "kitty"
        "jujutsu"
        "helix"
      ];
      inherit (inputs) wrappers;
      inherit (lib.types) attrsOf submodule deferredModuleWith;
      mkWrapperOption =
        moduleName:
        lib.mkOption {
          description = "${moduleName} config from lassulus/wrappers";

          type = attrsOf (deferredModuleWith {
            staticModules = [
              # { pkgs = lib.mkDefault pkgs; }
              "${wrappers}/modules/${moduleName}/module.nix"
              "${wrappers}/lib/modules/wrapper.nix"
              "${wrappers}/lib/modules/meta.nix"
            ];
          });
        };
    in
    {
      options.wrappers = lib.mkOption {
        description = "Wrappers from lassulus/wrappers";
        type = submodule {
          options = lib.genAttrs modules mkWrapperOption;
        };
      };
    }
  );
  config.perSystem =
    { pkgs, config, ... }:
    let
      inherit (inputs) wrappers;
      mkName =
        head: module:
        lib.mapAttrs' (
          attr: val:
          lib.nameValuePair (head + "-" + attr)
            (lib.evalModules {
              modules = [
                { pkgs = lib.mkDefault pkgs; }
                val
              ];
              specialArgs = {
                wlib = wrappers.lib;
              };
            }).config.wrapper
        ) module;
      packages = lib.foldlAttrs (
        acc: head: module:
        acc // mkName head module
      ) { } config.wrappers;
    in
    {
      inherit packages;
    };
}
