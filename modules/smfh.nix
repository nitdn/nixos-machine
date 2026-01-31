# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos.houses =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.houses;
      inherit (lib)
        types
        strings
        mkOption
        literalExpression
        ;
      inherit (types) attrsOf submodule;
      inherit (strings) hasPrefix normalizePath concatStringsSep;
      settingsFormat = pkgs.formats.json { };
      users = mkOption {
        type = attrsOf (submodule {
          freeformType = settingsFormat.type;
          options.version = mkOption {
            default = 3;
            example = 3;
          };
        });
        default = { };
        example = literalExpression ''
          {
            exampleUser = {
              files = [
                {
                  type = "copy";
                  source = "/sources/file";
                  target = "/outputs/file";
                  permissions = null;
                  uid = null;
                  gid = null;
                  clobber = null;
                  ignore_modifications = null;
                }
              ];
              clobber_by_default = false;
              version = 3;
            };
          }
        '';
        description = ''
          Per-user smfh configuration.
        '';
      };
      finalConfig = mkOption {
        readOnly = true;
      };
      mkAbsolutePath =
        targetUser: targetPath:
        if !hasPrefix "/" targetPath then
          normalizePath (
            concatStringsSep "/" [
              "/home"
              targetUser
              targetPath
            ]
          )
        else
          targetPath;
      mkAbsoluteConf =
        targetUser: targetConf:
        lib.recursiveUpdate targetConf {
          files = map (
            file:
            lib.recursiveUpdate file {
              target = mkAbsolutePath targetUser file.target;
            }
          ) targetConf.files;
        };
      mkUnit =
        targetUser: _targetConf:
        let
          generatedConfigFile =
            settingsFormat.generate "${targetUser}.smfh.json"
              cfg.finalConfig.users.${targetUser};
        in
        lib.nameValuePair ("smfh-relink@" + targetUser) {
          description = "Links smfh files on rebuild";
          path = lib.attrValues { inherit (pkgs) smfh; };
          wantedBy = [ "multi-user.target" ];
          script = "smfh activate ${generatedConfigFile}";
          serviceConfig = {
            User = targetUser;
            Type = "oneshot";
            RestartSec = 5;
            Restart = "on-failure";
          };
          unitConfig = {
            ConditionPathIsReadWrite = "/home/${targetUser}/.config";
            RequiresMountsFor = [ "/home/${targetUser}/" ];
          };
        };
    in
    {
      options.houses = { inherit users finalConfig; };
      config.houses.finalConfig.users = lib.recursiveUpdate cfg.users (
        lib.mapAttrs mkAbsoluteConf cfg.users
      );
      config.systemd.services = lib.mapAttrs' mkUnit cfg.users;
    };
  flake.modules.nixos.pc.imports = [ nixosModules.houses ];
}
