{
  inputs,
  ...
}:
{
  flake.modules.nixos.pc =
    {
      pkgs,
      ...
    }:
    {
      # Edit this configuration file to define what should be installed on
      # your system.  Help is available in the configuration.nix(5) man page
      # and in the NixOS manual (accessible by running ‘nixos-help’).

      # cleanup configs
      nix.optimise.automatic = true;
      nix.gc = {
        # WARN: Symlink store for home will not show up until you login
        # at which point its already too late
        # HACK: Turn off autogc indefinitely
        automatic = false;

        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      nix.settings.trusted-users = [
        "@wheel"
      ];
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
      ];
      nix.settings.auto-allocate-uids = true;

      # Bootloader.
      boot.loader.limine.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      networking = {
        nameservers = [
          # "1.1.1.1" # oh no
          "127.0.0.1"
          "::1"
        ];
        networkmanager.dns = "none";
      };
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      # networking.networkmanager.enable = true;

      # Display manager configuration
      # Broken on homed users
      # services.displayManager.cosmic-greeter.enable = true;
      #
      services.displayManager.gdm.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.power-profiles-daemon.enable = true;

      # services.desktopManager.cosmic.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Kolkata";

      # Select internationalisation properties.
      i18n.extraLocaleSettings = {
        LANGUAGE = "en_IN:en:C:bn_IN:hi_IN";
      };

      i18n.extraLocales = [
        "en_IN/UTF-8"
        "en_US.UTF-8/UTF-8"
        "bn_IN/UTF-8"
        "hi_IN/UTF-8"
      ];

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
      ];

      fonts.fontconfig.defaultFonts = {
        sansSerif = [
          "Atkinson Hyperlegible Next"
          "Noto Sans Bengali"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif Bengali"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Bengali"
        ];
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        jack.enable = true;

      };

      hardware.keyboard.qmk.enable = true;
      hardware.keyboard.qmk.keychronSupport = true;
      services.udev.packages = with pkgs; [
        sane-airscan
        via
      ];
      environment.systemPackages = with pkgs; [ via ];

      # Install firefox.
      programs.firefox.enable = true;
      programs.nh = {
        enable = true;
      };
    };
  meta.unfreeNames = [ "via" ];
}
