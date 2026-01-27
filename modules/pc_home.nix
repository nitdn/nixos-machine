# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  moduleWithSystem,
  inputs,
  ...
}:
{
  meta.username = "ssmvabaa";
  meta.unfreeNames = [ "obsidian" ];
  flake.modules.homeManager.pc = moduleWithSystem (
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (config) packages;
    in
    {
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      # home.username = "${username}";
      # home.homeDirectory = lib.mkForce "/home/${username}";

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "24.11"; # Please read the comment before changing.

      # The home.packages option allows you to install Nix packages into your
      # environment.
      home.packages = [
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
        #
        packages.naps2-wrapped
        pkgs.obsidian
        pkgs.p7zip
        pkgs.tlrc
        pkgs.scantailor-universal
        # inputs'.typeman.packages.default # typeman currently fails
      ];

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # programs.keepassxc.enable = true;

      programs.gh.enable = true;

      programs.zen-browser.enable = true;
      # stylix.targets.zen-browser.profileNames = [ "Default" ];

      # services.syncthing.enable = true;
      # services.syncthing = {
      #   # openDefaultPorts = true;
      # };
      programs.vesktop.enable = true;
    }
  );
  flake.modules.nixos.hmBase = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.startAsUserService = true;
      home-manager.sharedModules = [
        inputs.zen-browser.homeModules.default
      ];
      home-manager.backupFileExtension = "backup";
    };
  };
}
