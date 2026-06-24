# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.wrappers.kakoune-pc =
    { pkgs, ... }:
    let
      kakrc = pkgs.writeTextFile rec {
        name = "kakrc.kak";
        destination = "/share/kak/autoload/${name}";
        text = ''
          colorscheme catppuccin_mocha
          eval %sh{kak-lsp}
          hook -group lsp-filetype-nix global BufSetOption filetype=nix %{
              set-option buffer lsp_servers %{
                  [nixd]
                  root_globs = ["flake.nix", "shell.nix", ".git", ".hg"]
                  settings_section = "nixd"
                  [nixd.settings.nixd]
                  "nixpkgs.expr" = "import <nixpkgs> { }"
                  [nixd.settings.nixd.options]
                  nixos.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").nixosConfigurations.tjmaxxer.options"
                  flake-parts.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").debug.options"
                  flake-parts-perSystem.expr = "(builtins.getFlake \"/home/${username}/nixos-machine\").currentSystem.options"
                  }
              }


          lsp-enable
          addhl global/ number-lines -relative

          set-option global modelinefmt "%opt{lsp_modeline} %opt{modelinefmt}"

          map global user c ':comment-line<ret>' -docstring 'Comment out block'
          map global user = ':lsp-range-formatting<ret>' -docstring 'LSP range formatting'

          map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'

          map global goto d <esc>:lsp-definition<ret> -docstring 'LSP definition'
          map global goto r <esc>:lsp-references<ret> -docstring 'LSP references'
          map global goto y <esc>:lsp-type-definition<ret> -docstring 'LSP type definition'

          map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'

          map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
          map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
          map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
          map global object t '<a-semicolon>lsp-object Class Interface Module Namespace Struct<ret>' -docstring 'LSP class or module'
          map global object d '<a-semicolon>lsp-diagnostic-object error warning<ret>' -docstring 'LSP errors and warnings'
          map global object D '<a-semicolon>lsp-diagnostic-object error<ret>' -docstring 'LSP errors'
        '';
      };
    in
    {
      overrides = [
        {
          type = "override";
          data = prev: { plugins = prev.plugins or [ ] ++ [ kakrc ]; };
        }
      ];
    };
}
