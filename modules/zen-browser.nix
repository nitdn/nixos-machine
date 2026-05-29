# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  ...
}:
let
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    # Check these out at about:config
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
    # ...
  };

  extensions = [
    # To add additional extensions, find it on addons.mozilla.org, find
    # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
    # Then go to https://addons.mozilla.org/api/v5/addons/addon/!SHORT_ID!/ to get the guid
    (extension "adnauseam" "adnauseam@rednoise.org")
    # ...
  ];
  extraPolicies = {
    DNSOverHTTPS = {
      Enabled = true;
      ProviderURL = "https://jmfa1wa82x.cloudflare-gateway.com/dns-query";
    };
    DisableTelemetry = true;
    ExtensionSettings = builtins.listToAttrs extensions;

    SearchEngines = {
      Default = "ddg";
      Add = [
        {
          Name = "nixpkgs packages";
          URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@np";
        }
        {
          Name = "NixOS options";
          URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@no";
        }
        {
          Name = "NixOS Wiki";
          URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@nw";
        }
        {
          Name = "noogle";
          URLTemplate = "https://noogle.dev/q?term={searchTerms}";
          IconURL = "https://noogle.dev/favicon.ico";
          Alias = "@ng";
        }
      ];
    };
  };

in
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.wrapFirefox
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
          {
            extraPrefs = lib.concatLines (
              lib.mapAttrsToList (
                name: value: "lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});"
              ) prefs
            );
            inherit extraPolicies;
          }
        )
      ];
    };
}
