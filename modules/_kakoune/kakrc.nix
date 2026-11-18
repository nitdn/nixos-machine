# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ pkgs, ... }:
let
  kakrc = pkgs.writeText "kakrc.kak" /* kak */ ''
    set-option global ui_options terminal_status_on_top=false
    eval %sh{kak-lsp}


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


    # LSP markdown enablement
    face global InfoDefault               Information
    face global InfoBlock                 Information
    face global InfoBlockQuote            Information
    face global InfoBullet                Information
    face global InfoHeader                Information
    face global InfoLink                  Information
    face global InfoLinkMono              Information
    face global InfoMono                  Information
    face global InfoRule                  Information
    face global InfoDiagnosticError       Information
    face global InfoDiagnosticHint        Information
    face global InfoDiagnosticInformation Information
    face global InfoDiagnosticWarning     Information
  '';
  mawww-kak = pkgs.concatTextFile rec {
    # HAHAHAHAHHAHAHAHHAHAHAHAHAAHHAAHAAHAAAHAHHAAHHAHA I WIN
    name = "kakrc.local";
    # man 1 kak
    destination = "/share/kak/${name}";
    files = [
      ./mawww.kakrc
      kakrc
    ];
  };
in
{
  plugins = [
    mawww-kak
  ];
}
