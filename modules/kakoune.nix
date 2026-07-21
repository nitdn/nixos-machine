# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Baseline for a kakoune wrapper
{ inputs, config, ... }:

let
  inherit (config.flake) wrappers;
in
{
  flake = {
    modules.nixos.pc = { pkgs, ... }: {
      environment.systemPackages = [
        (wrappers.kakoune-pc.wrap {
          inherit pkgs;
        })
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
      plugins = [
        # needed for manpagers
        pkgs.kakounePlugins.kak-ansi
        # if its not in plugins it will hit priority issues
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
