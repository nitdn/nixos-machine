{ inputs, moduleWithSystem, ... }:
{
  flake.modules.homeManager.pc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      noctalia =
        cmd:
        [
          "noctalia-shell"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);
    in
    {
      # import the home manager module
      imports = [
        inputs.noctalia.homeModules.default
      ];
      # configure options
      programs.noctalia-shell = {
        enable = true;
        settings = {
          # configure noctalia here; defaults will
          # be deep merged with these attributes.
          bar = {
            density = "comfortable";
            position = "bottom";
            floating = true;
            widgets.left = [
              { id = "SystemMonitor"; }
              { id = "ActiveWindow"; }
              { id = "MediaMini"; }
            ]; # I am losing my mind
            widgets.center = [
              { id = "TaskbarGrouped"; }
              { id = "Clock"; }
            ];
            widgets.right = [
              { id = "ScreenRecorder"; }
              { id = "Tray"; }
              { id = "NotificationHistory"; }
              { id = "Battery"; }
              { id = "Volume"; }
              { id = "Brightness"; }
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ];
          };
          appLauncher = {
            enableClipboardHistory = true;
          };
          colorSchemes.predefinedScheme = "Dracula";
          dock.enabled = false; # who asked for an always visible dock?????????
        };
      };
      programs.niri.settings = {
        spawn-at-startup = [
          {
            command = [
              "noctalia-shell"
            ];
          }
        ];
        binds = {
          "Mod+Space".action.spawn = noctalia "launcher toggle";
          "Mod+Escape".action.spawn = noctalia "sessionMenu toggle";
          "Mod+G".action.spawn = noctalia "lockScreen lock";
          "Mod+V".action.spawn = noctalia "launcher clipboard";
          "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
          "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
          "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
          "XF86MonBrightnessUp".action.spawn = noctalia "brightness increase";
          "XF86MonBrightnessDown".action.spawn = noctalia "brightness decrease";
        };
      };
    };
  flake.modules.nixos.pc = moduleWithSystem (
    {
      inputs',
      pkgs,
    }:
    {
      imports = [
        inputs.noctalia.nixosModules.default
      ];
      hardware.i2c.enable = true;
      environment.systemPackages = [
        pkgs.ddcutil
        inputs'.noctalia.packages.default
      ];
    }
  );
}
