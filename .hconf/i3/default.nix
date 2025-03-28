{ lib
, config
, pkgs
, aurpkgs
, dir
, hconf
, lock
, terminal
, browser
, sswitcher
, pbar-start
, screenshot-full
, screenshot-gui }:

let
  i3-video-wallpaper = pkgs.stdenv.mkDerivation rec {
    name = "i3-video-wallpaper";

    src = pkgs.fetchFromGitHub {
      owner = "Zolyn";
      repo = "i3-video-wallpaper";
      rev = "69b6e6e02929edc5ee2b93c5c4f7542a752385ea";
      hash = "sha256-A3+B8FOoPC8bbAcG2pmO07dVsTjtqVkJKAptSs0k9ns=";
    };

    buildInputs = with pkgs; [
      imagemagick
      coreutils-full
      xorg.xrandr
      gnugrep
      xdotool
      xwinwrap
      mpv
      feh
      ps
    ];

    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp setup.sh $out/bin/i3-video-wallpaper
    '';

    postFixup = ''
      wrapProgram $out/bin/i3-video-wallpaper --set PATH ${lib.makeBinPath buildInputs}
    '';
  };
  video-bg = pkgs.stdenv.mkDerivation {
    name = "i3-bg";
    src = ./.;

    installPhase = ''
      mkdir -p $out/bin
      printf "\#!/usr/bin/env bash\n\n${i3-video-wallpaper}/bin/i3-video-wallpaper -bawn ${./bg.mp4}" >$out/bin/start
      chmod +x $out/bin/start
    '';
  };
in {
  enable = true;

  extraConfig = ''
    include ${hconf + /i3/i3-catppuccin}
  '';

  config = let
    mkMenu = args: "${config.programs.rofi.finalPackage}/bin/rofi ${args}";
    drun = mkMenu "-show drun -run-command \"i3-msg exec '{cmd}'\" -show-icons -sidebar-mode -application-fallback-icon ${./rofi-default-icon.png}";
    powermenu = mkMenu "-show power-menu -modi \"power-menu:rofi-power-menu --choices=logout/shutdown/reboot\"";
    calc = mkMenu "-show calc -modi calc -no-show-match -no-sort -location 7 -calc-command 'printf \"{result}\" | ${pkgs.xclip.out}/bin/xclip -i -selection CLIPBOARD'";
    file-browser = mkMenu "-show file-browser-extended";
    bluetooth = "rofi-bluetooth";
    keepmenu = "keepmenu";
  in rec {
    menu = drun;
    modifier = "Mod4";
    defaultWorkspace = "workspace number 1";

    inherit terminal;

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
      # (mkAlways "${feh.out}/bin/feh --no-fehbg --bg-scale ${dir}/.bg")
      (mkAlways "${video-bg.out}/bin/start")
      (mkAlways "${kitti3.out}/bin/kitti3 -n caterwaul -p CC -s 0.4 0.4")
      (mkOnce "${lxqt.lxqt-policykit.out}/bin/lxqt-policykit-agent")
      (mkOnce "${picom.out}/bin/picom -cbf --config ${hconf + /picom/picom.conf}")
      (mkOnce "${flameshot.out}/bin/flameshot")
      (mkOnce "${networkmanagerapplet.out}/bin/nm-applet")
      (mkOnce "${birdtray.out}/bin/birdtray")
      (mkOnce "${keepassxc.out}/bin/keepassxc")
      (mkOnce "${blueman.out}/bin/blueman-applet")
      (mkOnce "${warpd.out}/bin/warpd --config ${hconf + /warpd/warpd.conf}")
      (mkOnce "${rclone.out}/bin/rclone mount AuraGDrive: ${dir}/CloudData/AuraGDrive")
    ]);

    keybindings = let
      mod = modifier;
      mkWorkspaceFocus = last: if last == 0 then { } else {
        "${mod}+Mod2+KP_${builtins.toString last}" = "workspace number ${builtins.toString last}";
      } // mkWorkspaceFocus (last - 1);
      mkWorkspaceMove = last: if last == 0 then { } else {
        "${mod}+Mod1+Mod2+KP_${builtins.toString last}" = "move container to workspace number ${builtins.toString last}";
      } // mkWorkspaceMove (last - 1);
      mkAudioCtrl = args: "exec --no-startup-id ${pkgs.pulseaudio.out}/bin/pactl ${args}";
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
      # "${mod}+z" = "exec --no-startup-id ${pkgs.autorandr.out}/bin/autorandr -c";

      # modify audio settings
      "${mod}+k" = mkAudioCtrl "set-sink-volume @DEFAULT_SINK@ +10%";
      "${mod}+j" = mkAudioCtrl "set-sink-volume @DEFAULT_SINK@ -10%";
      "${mod}+n" = mkAudioCtrl "set-sink-mute @DEFAULT_SINK@ toggle";
      "${mod}+m" = mkAudioCtrl "set-source-mute @DEFAULT_SOURCE@ toggle";

      # clipboard management
      "${mod}+p" = "exec --no-startup-id ${aurpkgs.dont-repeat-yourself.out}/bin/dont-repeat-yourself load";
      "${mod}+Shift+p" = "exec --no-startup-id ${aurpkgs.dont-repeat-yourself.out}/bin/dont-repeat-yourself save";

      # calculator
      "${mod}+o" = "exec --no-startup-id ${calc}";

      # file browser
      "${mod}+i" = "exec --no-startup-id ${file-browser}";

      # password manager
      "${mod}+u" = "exec --no-startup-id ${keepmenu}";

      # bluetooth
      "${mod}+b" = "exec --no-startup-id ${bluetooth}";

      # keyboard layout
      "${mod}+g" = "exec --no-startup-id ${pkgs.xorg.setxkbmap.out}/bin/setxkbmap us";
      "${mod}+t" = "exec --no-startup-id ${pkgs.xorg.setxkbmap.out}/bin/setxkbmap ca";

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

      # reload config
      "${mod}+Shift+c" = "reload";

      # restart i3 inplace
      "${mod}+Shift+r" = "restart";

      # scratchpad
      "${mod}+Mod2+KP_0" = "scratchpad show; floating disable";
      "${mod}+Mod1+Mod2+KP_0" = "move scratchpad";

      # floating windows are the worst
      "${mod}+End" = "floating toggle";

      # powermenu
      "${mod}+BackSpace" = "exec ${powermenu}";
    } // mkWorkspaceFocus 9 // mkWorkspaceMove 9;

    floating = {
      titlebar = true;
      border = 2;
      inherit modifier;

      criteria = [
        {
          class = "dont-repeat-yourself";
        }
      ];
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
        {
          command = "focus";

          criteria = {
            class = "vesktop";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "firefox";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "FreeTube";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "dont-repeat-yourself";
          };
        }
      ];
    };

    assigns = {
      "1" = [
        {
          class = "vesktop";
        }
      ];
      "2" = [
        {
          class = "firefox";
        }
      ];
      "3" = [
        {
          class = "steam";
        }
        {
          class = "heroic";
        }
      ];
      "9" = [
        {
          class = "FreeTube";
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
