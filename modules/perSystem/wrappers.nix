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
    { pkgs, ... }:
    let
      modules = [
        "kitty"
        "niri"
      ];
      inherit (inputs) wrappers;
      inherit (lib.types) attrsOf submodule submoduleWith;
      mkWrapperOption =
        moduleName:
        lib.mkOption {
          description = "${moduleName} config from lassulus/wrappers";
          type = attrsOf (submoduleWith {
            specialArgs = {
              wlib = wrappers.lib;
            };
            modules = [
              { pkgs = lib.mkDefault pkgs; }
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
}
