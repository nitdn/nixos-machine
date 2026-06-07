# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, ... }:
let
  inherit (config.flake) wrappers;
in
{
  flake.wrappers.jujutsu-pc =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.jujutsu ];
      settings.user.name = "Nitesh Kumar Debnath";
      settings.user.email = "nitkdnath@gmail.com";
      settings.signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };
      settings.template-aliases.default_commit_description = ''
        "scope: message
        JJ: body

        JJ: Closes #NNNN
        "
      '';
    };

  flake.modules.nixos.pc =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ (wrappers.jujutsu-pc.wrap { inherit pkgs; }) ];
    };
}
