{ lib
, pkgs
, dir
, hconf
, lock
, terminal
, browser
, sswitcher
, pbar-start
, screenshot-full
, screenshot-gui }:

{
  enable = true;

  extraConfig = ''
    include ${hconf + /i3/i3-catppuccin}
  '';

  config = rec {
    inherit terminal;
    modifier = "Mod4";
    menu = "${pkgs.rofi.out}/bin/rofi -show drun -run-command \"i3-msg exec '{cmd}'\" -show-icons";
    defaultWorkspace = "workspace number 1";
    #workspaceLayout = "tabbed";

    startup = let
      mkCmd = command: always: {
        inherit command always;
        notification = false;
      };
      mkAlways = command: mkCmd command true;
      mkOnce = command: mkCmd command false;
    in [
      (mkAlways "${pbar-start.out}/bin/launch")
      (mkOnce "${sswitcher.out}/bin/sswitcher")
    ] ++ (with pkgs; [
      (mkAlways "${autorandr.out}/bin/autorandr -c")
      (mkAlways "${feh.out}/bin/feh --no-fehbg --bg-scale ${dir}/.bg")
      (mkAlways "${kitti3.out}/bin/kitti3 -n caterwaul -p CC -s 0.4 0.4")
      (mkOnce "${lxqt.lxqt-policykit.out}/bin/lxqt-policykit-agent")
      (mkOnce "${picom.out}/bin/picom -cbf --config ${hconf + /picom/picom.conf}")
      (mkOnce "${openrgb.out}/bin/openrgb --startminimized --profile \"Trans-Purple\"")
      (mkOnce "${dunst.out}/bin/dunst")
      (mkOnce "${flameshot.out}/bin/flameshot")
      (mkOnce "${networkmanagerapplet.out}/bin/nm-applet")
      (mkOnce "${sirikali.out}/bin/sirikali")
      (mkOnce "${keepassxc.out}/bin/keepassxc")
      (mkOnce "${qbittorrent.out}/bin/qbittorrent")
      (mkOnce "${blueman.out}/bin/blueman-applet")
      (mkOnce "${rclone.out}/bin/rclone mount AuraGDrive: ${dir}/CloudData/AuraGDrive")
    ]);

    keybindings = let
      mod = modifier;
      wspace_key = "${mod}+Mod2+KP";
      wspace_mv_key = "${mod}+Mod1+Mod2+KP";
      wspace_cmd = "workspace number";
      wspace_mv_cmd = "move container to workspace number";
    in {
      # kill windows
      "${mod}+Delete" = "kill";

      # launch programs
      "${mod}+Return" = "exec ${terminal}";
      "${mod}+space" = "exec ${menu}";
      "${mod}+c" = "exec ${browser}";

      # pop-up kitty
      "${mod}+x" = "nop caterwaul";

      # screenshot
      "Print" = "exec --no-startup-id ${screenshot-full}";
      "${mod}+Print" = "exec --no-startup-id ${screenshot-gui}";

      # lock screen
      "${mod}+l" = "exec --no-startup-id ${lock}";

      # reload monitor config with autorandr
      "${mod}+z" = "exec --no-startup-id autorandr -c";

      # modify audio settings
      "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
      "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
      "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

      # change focus
      "${mod}+Left" = "focus left";
      "${mod}+Down" = "focus down";
      "${mod}+Right" = "focus right";
      "${mod}+Up" = "focus up";

      # move window
      "${mod}+Mod1+Left" = "move left";
      "${mod}+Mod1+Down" = "move down";
      "${mod}+Mod1+Right" = "move right";
      "${mod}+Mod1+Up" = "move up";

      # split horizontal
      "${mod}+h" = "split h";

      # split vertical
      "${mod}+v" = "split v";

      # fullscreen
      "${mod}+f" = "fullscreen toggle";

      # change layout
      "${mod}+a" = "layout stacking";
      "${mod}+s" = "layout tabbed";
      "${mod}+d" = "layout toggle split";

      # open powermenu
      "${mod}+BackSpace" = "mode \"powermenu\"";

      # reload config
      "${mod}+Shift+c" = "reload";

      # restart i3 inplace
      "${mod}+Shift+r" = "restart";

      # switch to workspace
      "${wspace_key}_1" = "${wspace_cmd} 1";
      "${wspace_key}_2" = "${wspace_cmd} 2";
      "${wspace_key}_3" = "${wspace_cmd} 3";
      "${wspace_key}_4" = "${wspace_cmd} 4";
      "${wspace_key}_5" = "${wspace_cmd} 5";
      "${wspace_key}_6" = "${wspace_cmd} 6";
      "${wspace_key}_7" = "${wspace_cmd} 7";
      "${wspace_key}_8" = "${wspace_cmd} 8";
      "${wspace_key}_9" = "${wspace_cmd} 9";

      # move window to workspace
      "${wspace_mv_key}_1" = "${wspace_mv_cmd} 1";
      "${wspace_mv_key}_2" = "${wspace_mv_cmd} 2";
      "${wspace_mv_key}_3" = "${wspace_mv_cmd} 3";
      "${wspace_mv_key}_4" = "${wspace_mv_cmd} 4";
      "${wspace_mv_key}_5" = "${wspace_mv_cmd} 5";
      "${wspace_mv_key}_6" = "${wspace_mv_cmd} 6";
      "${wspace_mv_key}_7" = "${wspace_mv_cmd} 7";
      "${wspace_mv_key}_8" = "${wspace_mv_cmd} 8";
      "${wspace_mv_key}_9" = "${wspace_mv_cmd} 9";
    };

    modes = {
      powermenu = {
        "l" = "exec --no-startup-id ${lock}, mode \"default\"";
        "e" = "exec --no-startup-id i3-msg exit, mode \"default\"";
        "h" = "exec --no-startup-id ${lock} && systemctl hibernate, mode \"default\"";
        "r" = "exec --no-startup-id systemctl reboot, mode \"default\"";
        "s" = "exec --no-startup-id systemctl poweroff -i, mode \"default\"";

        # back to normal: Enter, Escape, or Backspace
        "Return" = "mode \"default\"";
        "Escape" = "mode \"default\"";
        "BackSpace" = "mode \"default\"";
      };
    };

    floating = {
      titlebar = true;
      border = 2;
      inherit modifier;
    };

    focus = {
      followMouse = true;
      mouseWarping = true;
    };

    window = {
      titlebar = false;
      border = 2;

      commands = [
        {
          command = "kill";

          criteria = {
            class = ".blueman-applet-wrapped";
          };
        }
      ];
    };

    gaps = {
      smartBorders = "on";
      inner = 6;
      outer = 2;
    };

    fonts = {
      names = [ "pango" ];
      style = "monospace";
      size = 8.0;
    };

    bars = lib.mkForce [ ];
  };
}
