# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Baseline for a kakoune wrapper
{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config.meta) username;
in
{
  flake = {
    modules.nixos.pc = { pkgs, ... }: {
      wrappers.kakoune-pc.enable = true;
      environment.systemPackages = [
        pkgs.kdePackages.kate # Needed for text editor support
      ];
      environment.variables = {
        EDITOR = "kak";
        VISUAL = "kak";
        PAGER = "kak -ro -e 'rmhl global/number-lines_-relative'";
      };
    };
    wrappers.kakoune-pc = { pkgs, ... }: {
      imports = [ inputs.nix-devshells.wrapperModules.kakoune ];
      wrapperVariants.kakn.flags."-C" = "nix";
      wrapperVariants.kakn.exePath = "bin/kak";

      runShell = [
        ''
          export NIX_CONFIG="$(${lib.getExe pkgs.gnused} -E 's/ pipe-operator( |$)/ pipe-operators\1/' /etc/nix/nix.conf)
          $NIX_CONFIG"
        ''
      ];
      plugins = [
        # needed for manpagers
        pkgs.kakounePlugins.kak-ansi
        # if its not in plugins it will hit priority issues
        (pkgs.writeTextDir "/share/kak/autoload/plugins/lsp/nix.kak" ''
          hook -group lsp-filetype-nix global BufSetOption filetype=nix %{
            set-option buffer lsp_servers %{
               [nixd]
               root_globs = ["flake.nix", "shell.nix", ".git", ".hg"]
               settings_section = "nixd"
               [nixd.settings.nixd]
               nixpkgs.expr = "import <nixpkgs> { }"
               [nixd.settings.nixd.options]
               nixos.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").nixosConfigurations.tjmaxxer.options"
               flake-parts.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").debug.options"
               flake-parts-perSystem.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").currentSystem.options"
               }
            }
        '')
        (pkgs.writeTextDir "/share/kak/autoload/plugins/lsp/nushell.kak" ''
          hook -group lsp-filetype-nu global BufCreate .*[.]nu %{
            set-option buffer filetype nu
          }
          hook -group lsp-filetype-nu global BufSetOption filetype=nu %{
            set-option buffer formatcmd "nufmt --stdin"
            set-option buffer lsp_servers %{
              [nu-lsp]
              command = "nu"
              args = ["--lsp"]
              root_globs = [".nu", ".git", ".hg"]
            }
          }
        '')
      ];
    };
  };
}
