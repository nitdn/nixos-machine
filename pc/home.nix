{ config, moduleWithSystem, ... }:
let
  homeModules = config.flake.modules.homeManager;
in
{
  perSystem.pc.username = "ssmvabaa";
  perSystem.pc.unfreeNames = [ "obsidian" ];
  flake.modules.homeManager.default = moduleWithSystem (
    {
      pkgs,
      config,
      ...
    }:
    let
      leader.key = "alt+space";
      packages = config.packages;
    in
    { config, lib, ... }:
    {
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      imports = [
        ./helix.nix
        ./gitui.nix
        ./niri.nix
        homeModules.noctalia
        # inputs.zen-browser.homeModules.twilight
      ];
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
      home.packages = with pkgs; [
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
        (writeShellScriptBin "xterm" ''
          ghostty "$@"
        '')
        packages.naps2-wrapped
        obsidian
        p7zip
        tlrc
        scantailor-universal
        # inputs'.typeman.packages.default # typeman currently fails
      ];

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
        "${config.xdg.configHome}/waybar/power_menu.xml".source = ./power_menu.xml;
        "${config.xdg.configHome}/starship.toml".source = lib.mkForce (
          pkgs.fetchurl {
            url = "https://starship.rs/presets/toml/jetpack.toml";
            hash = "sha256-qCN4jI/LuMgyM80J5LZctCSuC8NzPrC+WlruFQUxjF8=";
          }
        );
      };
      # Home Manager can also manage your environment variables through
      # 'home.sessionVariables'. These will be explicitly sourced when using a
      # shell provided by Home Manager. If you don't want to manage your shell
      # through Home Manager then you have to manually source 'hm-session-vars.sh'
      # located at either
      #
      #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  /etc/profiles/per-user/${username}/etc/profile.d/hm-session-vars.sh
      #

      home.sessionVariables = {
        EDITOR = "hx";
        TERMINAL = "ghostty";
        # EDITOR = "emacs";
      };
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      programs.fish.enable = true;
      programs.fish.shellAbbrs = {
        gco = "git checkout";
        npu = "nix-prefetch-url";
        rm = "y";
      };
      programs.eza = {
        enable = true;
      };

      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "y";

        settings = {
          manager = {
            show_hidden = true;
          };
          preview = {
            max_width = 1000;
            max_height = 1000;
          };
        };
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.git = {
        enable = true;
        userName = "John Doe";
        userEmail = "johndoe@example.com";
      };

      programs.ghostty = {
        enable = true;
        # settings.window-decoration = "server";
        # settings.font-family = [ "Noto Sans Bengali" ];
        settings.keybind = [
          # "ctrl+h=goto_split:left"
          # "ctrl+l=goto_split:right"
          # "ctrl+j=goto_split:down"
          # "ctrl+k=goto_split:up"
          "${leader.key}>backslash=new_window"
          # "${leader.key}>minus=new_split:down"
          "${leader.key}>shift+backslash=new_window"
          # "${leader.key}>ctrl+minus=new_split:down"
        ];
      };

      programs.starship = {
        enable = true;
      };

      programs.keepassxc.enable = true;

      programs.fzf = {
        enable = true;
      };
      programs.zoxide = {
        enable = true;
      };
      programs.gh.enable = true;

      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
          batpipe
        ];
      };

      programs.zen-browser.enable = true;
      stylix.targets.zen-browser.profileNames = [ "Default" ];

      services.syncthing.enable = true;
      services.syncthing = {
        # openDefaultPorts = true;
      };
      programs.btop.enable = true;
      programs.lutris = {
        enable = true;
        extraPackages = with pkgs; [
          gamemode
          gamescope
          mangohud
          umu-launcher
          winetricks
        ];
      };
      programs.vesktop.enable = true;

      stylix.targets.helix.enable = false;
    }
  );
}
