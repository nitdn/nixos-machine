{
  config,
  lib,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    nautilus
    xwayland-satellite
    wl-clipboard
    libnotify
    brightnessctl
  ];

  services.mako.enable = true;
  programs.waybar.enable = true;

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty -e";
      };
    };
  };
  programs.niri.settings.layout.gaps = 0;
  programs.niri.settings.prefer-no-csd = true;
  programs.niri.settings.outputs.DP-2 = {
    mode = {
      height = 1080;
      width = 1920;
    };
  };
  programs.niri.settings.spawn-at-startup = [
    {
      command = [
        "ckb-next"
        "--background"
      ];
    }
    { command = [ "xwayland-satellite" ]; }
    { command = [ "ghostty" ]; }
    { command = [ "zen-beta" ]; }
    { command = [ "obsidian" ]; }
    { command = [ "waybar" ]; }
  ];
  programs.niri.settings.environment = {
    DISPLAY = ":0";
  };

  programs.niri.settings.input.mouse = {
    accel-profile = "flat";
    accel-speed = -0.7;
  };
  programs.niri.settings.animations.workspace-switch.kind.spring = {
    damping-ratio = 1.0;
    epsilon = 0.0001;
    stiffness = 1000;
  };

  programs.niri.settings.binds = with config.lib.niri.actions; {
    "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
    "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
    "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";

    "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "5%+";
    "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "5%-";

    "Mod+Space".action = spawn "fuzzel";
    "Mod+1".action = focus-workspace 1;
    "Mod+Slash".action = show-hotkey-overlay;
    "Mod+O" = {
      action = toggle-overview;
      repeat = false;
    };

    "Mod+Q" = {
      action = close-window;
      repeat = false;
    };
    "Mod+T".action = spawn "ghostty";
    "Mod+B".action = spawn "zen-twilight";

    # Default movement keymaps
    # ←h ↓j ↑k →l
    "Mod+Left".action = focus-column-left;
    "Mod+Down".action = focus-window-down;
    "Mod+Up".action = focus-window-up;
    "Mod+Right".action = focus-column-right;
    "Mod+H".action = focus-column-left;
    "Mod+J".action = focus-window-down;
    "Mod+K".action = focus-window-up;
    "Mod+L".action = focus-column-right;

    "Mod+Ctrl+Left".action = move-column-left;
    "Mod+Ctrl+Down".action = move-window-down;
    "Mod+Ctrl+Up".action = move-window-up;
    "Mod+Ctrl+Right".action = move-column-right;
    "Mod+Ctrl+H".action = move-column-left;
    "Mod+Ctrl+J".action = move-window-down;
    "Mod+Ctrl+K".action = move-window-up;
    "Mod+Ctrl+L".action = move-column-right;
    # ---

    # Workspaces
    "Mod+Page_Down".action = focus-workspace-down;
    "Mod+Page_Up".action = focus-workspace-up;
    "Mod+N".action = focus-workspace-down;
    "Mod+U".action = focus-workspace-up;
    "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
    "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
    "Mod+Ctrl+N".action = move-column-to-workspace-down;
    "Mod+Ctrl+U".action = move-column-to-workspace-up;
    "Mod+Shift+Page_Down".action = move-workspace-down;
    "Mod+Shift+Page_Up".action = move-workspace-up;
    "Mod+Shift+N".action = move-workspace-down;
    "Mod+Shift+U".action = move-workspace-up;
    # ---

    # Column manipulation
    # The following binds move the focused window in and out of a column.
    # If the window is alone, they will consume it into the nearby column to the side.
    # If the window is already in a column, they will expel it out.
    "Mod+BracketLeft".action = consume-or-expel-window-left;
    "Mod+BracketRight".action = consume-or-expel-window-right;

    # Consume one window from the right to the bottom of the focused column.
    "Mod+Comma".action = consume-window-into-column;
    # Expel the bottom window from the focused column to the right.
    "Mod+Period".action = expel-window-from-column;

    "Mod+R".action = switch-preset-column-width;
    "Mod+Shift+R".action = switch-preset-window-height;
    "Mod+Ctrl+R".action = reset-window-height;
    "Mod+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;

    # Expand the focused column to space not taken up by other fully visible columns.
    # Makes the column "fill the rest of the space".
    "Mod+Ctrl+F".action = expand-column-to-available-width;

    "Mod+C".action = center-column;

    # Center all fully visible columns on screen.
    "Mod+Ctrl+C".action = center-visible-columns;

    # Finer width adjustments.
    # This command can also:
    # * set width in pixels: "1000"
    # * adjust width in pixels: "-5" or "+5"
    # * set width as a percentage of screen width: "25%"
    # * adjust width as a percentage of screen width: "-10%" or "+10%"
    # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
    # set-column-width "100" will make the column occupy 200 physical screen pixels.
    "Mod+Minus".action = set-column-width "-10%";
    "Mod+Equal".action = set-column-width "+10%";

    # Finer height adjustments when in column with other windows.
    "Mod+Shift+Minus".action = set-window-height "-10%";
    "Mod+Shift+Equal".action = set-window-height "+10%";

    "Print".action = screenshot;
    "Ctrl+Print".action.screenshot-screen = { };
    "Alt+Print".action = screenshot-window;

    "Mod+Shift+E".action = quit;
    "Mod+Ctrl+Shift+E".action = quit { skip-confirmation = true; };

    "Mod+Plus".action = set-column-width "+10%";

  };
}
