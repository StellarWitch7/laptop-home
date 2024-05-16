{ config, lib, pkgs, ... }:

let
  aurpkgs = import (fetchTarball https://github.com/StellarWitch7/nurpkgs/archive/master.tar.gz) { };
  browser = config.home.sessionVariables.BROWSER;
  screenshotter = "${pkgs.flameshot.out}/bin/flameshot";
  screenshot-gui = "${screenshotter} gui";
  screenshot-full = "${screenshotter} full";
  lock = "${i3-lock.out}/bin/i3-lock-blurred";
  pbar-start = with pkgs; writeShellScriptBin "launch" ''
    ${polybarFull.out}/bin/polybar-msg cmd quit
    ${polybarFull.out}/bin/polybar
  '';
  i3-lock = with pkgs; writeShellScriptBin "i3-lock-blurred" ''
    img=/tmp/i3lock.png

    # suspend message display
    pkill -u "$USER" -USR1 dunst
    sleep 1

    # take screenshot
    ${scrot.out}/bin/scrot -o $img

    # blur screenshot
    ${imagemagick.out}/bin/convert $img -scale 10% -scale 1000% $img

    # lock the screen
    ${i3lock.out}/bin/i3lock -n -i $img

    # resume message display
    pkill -u "$USER" -USR2 dunst
  '';
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aur";
  home.homeDirectory = "/home/aur";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [ /etc/nixos/default-home.nix ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    aurpkgs.moth-lang
    aurpkgs.vault
    aurpkgs.nixbrains
    aurpkgs.ImageSorter
    (writeShellScriptBin "recon-gdrive" ''
      ${rclone.out}/bin/rclone config reconnect AuraGDrive:
      nohup ${rclone.out}/bin/rclone mount AuraGDrive: ~/CloudData/AuraGDrive &
    '')
    (writeShellScriptBin "hotspot" ''
      pkexec --user root ${linux-wifi-hotspot.out}/bin/create_ap wlp0s20f3 wlp0s20f3 "solanix" "$1" --mkconfig /etc/create_ap.conf -g 1.1.1.1
    '')
    (writeShellScriptBin "hotspot-gui" ''
      ${linux-wifi-hotspot.out}/bin/wihotspot-gui "$@"
    '')
    bottom
    octave
    xplr
    firefox
    vlc
    haruna
    gitnr
    calibre
    libreoffice
    hunspell
    git
    gitAndTools.gh
    hunspellDicts.en_GB-ise
    yt-dlp
    mindustry-server
    waydroid
    pavucontrol
    catppuccin
    catppuccin-cursors
    catppuccin-papirus-folders
    playonlinux
    lutris
    unstable.invidtui
    xclip
    glances
    keepassxc
    hyfetch
    unstable.vesktop
    starship
    #spotify
    #spotifywm
    #spicetify-cli
    #spotdl
    gnome.file-roller
    gnome.nautilus
    nano
    freshfetch
    bruno
    nanorc
    kitty-themes
    vscode
    xed-editor
    gnome.ghex
    gnome.gnome-disk-utility
    krita
    ffmpeg
    nautilus-open-any-terminal
    tmux
    unstable.jetbrains.rust-rover
    jetbrains.rider
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.pycharm-professional
  ];

  xsession = {
    enable = true;

    numlock.enable = true;


    windowManager.i3 = {
      enable = true;

      extraConfig = ''
        include ~/.config/i3/i3-catppuccin
      '';

      config = {
        modifier = "Mod4";
        terminal = "${pkgs.kitty.out}/bin/kitty";
        menu = "${pkgs.rofi.out}/bin/rofi -show drun -run-command \"i3-msg exec '{cmd}'\" -show-icons";
        #workspaceLayout = "tabbed";
        defaultWorkspace = "workspace number 1";

        startup = with pkgs; [
          { command = "${autorandr.out}/bin/autorandr -c"; always = true; notification = false; }
          { command = "${feh.out}/bin/feh --no-fehbg --bg-scale $HOME/.bg"; always = true; notification = false; }
          { command = "${pbar-start.out}/bin/launch"; always = true; notification = false; }
          { command = "${lxqt.lxqt-policykit.out}/bin/lxqt-policykit-agent"; always = false; notification = false; }
          { command = "${picom.out}/bin/picom -cbf --config ~/.config/picom/picom.conf"; always = false; notification = false; }
          { command = "${openrgb.out}/bin/openrgb --startminimized"; always = false; notification = false; }
          { command = "${dunst.out}/bin/dunst"; always = false; notification = false; }
          { command = "${flameshot.out}/bin/flameshot"; always = false; notification = false; }
          { command = "${networkmanagerapplet.out}/bin/nm-applet"; always = false; notification = false; }
          { command = "${sirikali.out}/bin/sirikali"; always = false; notification = false; }
          { command = "${qbittorrent.out}/bin/qbittorrent"; always = false; notification = false; }
          { command = "${blueman.out}/bin/blueman-applet"; always = false; notification = false; }
          { command = "${unstable.indicator-sound-switcher.out}/bin/indicator-sound-switcher"; always = false; notification = false; }
          { command = "${steam.out}/bin/steam"; always = false; notification = false; }
          { command = "${rclone.out}/bin/rclone mount AuraGDrive: ~/CloudData/AuraGDrive"; always = false; notification = false; }
        ];

        keybindings = let
          mod = config.xsession.windowManager.i3.config.modifier;
          wspace_key = "${mod}+Mod2+KP";
          wspace_mv_key = "${mod}+Mod1+Mod2+KP";
          wspace_cmd = "workspace number";
          wspace_mv_cmd = "move container to workspace number";
          menu = config.xsession.windowManager.i3.config.menu;
          term = config.xsession.windowManager.i3.config.terminal;
        in {
          # kill windows
          "${mod}+Delete" = "kill";

          # launch programs
          "${mod}+Return" = "exec ${term}";
          "${mod}+space" = "exec --no-startup-id ${menu}";
          "${mod}+c" = "exec ${browser}";

          # screenshot
          "Print" = "exec --no-startup-id ${screenshot-full}";
          "${mod}+Print" = "exec --no-startup-id ${screenshot-gui}";

          # lock screen
          "${mod}+l" = "exec --no-startup-id ${lock}";

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
          "F11" = "fullscreen toggle";

          # change layout
          "${mod}+a" = "layout stacking";
          "${mod}+s" = "layout tabbed";
          "${mod}+d" = "layout toggle split";

          # open powermenu
          "${mod}+Backspace" = "mode \"powermenu\"";

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
            "Backspace" = "mode \"default\"";
          };
        };

        floating = {
          titlebar = true;
          border = 2;
          modifier = "${config.xsession.windowManager.i3.config.modifier}";
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
    };
  };

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      # If not running interactively, don't do anything
      [[ $- != *i* ]] && return

      # If root, don't do anything
      [[ "$(whoami)" = "root" ]] && return

      # Start starship
      eval "$(${pkgs.starship.out}/bin/starship init bash)"

      # Source the rest of bashrc
      source ~/.bashrc.mine
    '';
  };

  services.gpg-agent = {
    enable = true;

    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };

    cursorTheme = {
      name = "Future-cyan-cursors";
    };

    iconTheme = {
      name = "Papirus-Dark";
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    #".config/dosomething/config.toml".source = /path/to/dosomething/config.toml;

    #".gradle/gradle.properties".text = ''
    #  org.gradle.console=verbose
    #  org.gradle.daemon.idletimeout=3600000
    #'';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/aurora/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    GAMES = "$HOME/Games";
    APPS = "$HOME/Apps";

    PATH = "$PATH:$HOME/.bin:$GAMES:$HOME/.cargo/bin:$HOME/.nix-profile/bin:$HOME/.spicetify:/var/lib/snapd/snap/bin";

    EDITOR = "nano";
    BROWSER = "firefox";

    HISTCONTROL = "ignoredups:ignorespace";
    HISTTIMEFORMAT = "[%Y/%m/%d @ %H:%M:%S] ";

    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";

    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
