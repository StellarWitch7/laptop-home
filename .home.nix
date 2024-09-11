{ config, lib, pkgs, ... }:

let
  aurpkgs = import (fetchTarball https://github.com/StellarWitch7/nurpkgs/archive/master.tar.gz) { };
  editor = "${pkgs.nano.out}/bin/nano";
  browser = "${pkgs.firefox.out}/bin/firefox";
  screenshotter = "${pkgs.flameshot.out}/bin/flameshot";
  screenshot-gui = "${screenshotter} gui";
  screenshot-full = "${screenshotter} full";
  lock = "${i3-lock.out}/bin/i3-lock-blurred";
  sswitcher = with pkgs; writeShellScriptBin "sswitcher" ''
    exec nix-shell -p indicator-sound-switcher --run indicator-sound-switcher
  '';
  pbar-start = with pkgs; writeShellScriptBin "launch" ''
    ${polybarFull.out}/bin/polybar-msg cmd quit
    exec ${polybarFull.out}/bin/polybar
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
  name = "aur";
  dir = "/home/${name}";
  hconf = "${dir}/.hconf";
in rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = name;
  home.homeDirectory = dir;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [
    /etc/nixos/default-home.nix
    "${fetchTarball https://github.com/catppuccin/nix/archive/main.tar.gz}/modules/home-manager"
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; with nur.repos; [
    sswitcher
    aurpkgs.moth-lang
    aurpkgs.git-nixed
    aurpkgs.vault
    aurpkgs.nixbrains
    aurpkgs.bar # fun game :D
    aurpkgs.ImageSorter
    #aurpkgs.playit
    (writeShellScriptBin "recon-gdrive" ''
      ${rclone.out}/bin/rclone config reconnect AuraGDrive:
      nohup ${rclone.out}/bin/rclone mount AuraGDrive: ~/CloudData/AuraGDrive &
    '')
    (writeShellScriptBin "cs-fmt" ''
      nix-shell -p dotnet-sdk csharpier --run "dotnet-csharpier $@"
    '')
    (writeShellScriptBin "hotspot" ''
      pkexec --user root ${linux-wifi-hotspot.out}/bin/create_ap wlp0s20f3 wlp0s20f3 "solanix" "$1" --mkconfig /etc/create_ap.conf -g 1.1.1.1
    '')
    (writeShellScriptBin "hotspot-gui" ''
      exec ${linux-wifi-hotspot.out}/bin/wihotspot-gui "$@"
    '')
    #(unstable.discord.override { withVencord = true; withOpenASAR = true; }) # broken
    unstable.vesktop
    octave
    xplr
    firefox
    handbrake
    vlc
    audacity
    #haruna
    gitnr
    calibre
    simplescreenrecorder
    freetube
    firefox
    neovim
    libreoffice
    hunspell
    tree
    #obsidian
    aseprite #pikopixel
    blockbench
    git
    gitAndTools.gh
    hunspellDicts.en_GB-ise
    yt-dlp
    #kampka.nixify # no longer available?
    bottom
    sirikali
    flameshot
    qbittorrent
    #soundux # unmaintained
    openrgb
    rclone
    picom
    bespokesynth
    dunst
    blueman
    kitty
    linux-wifi-hotspot
    feh
    prismlauncher
    lxqt.lxqt-policykit
    autorandr
    unzip
    with-shell
    ngrok
    tailscale-systray
    #riseup-vpn
    networkmanagerapplet
    mindustry-server
    #waydroid
    pavucontrol
    playonlinux
    unstable.lutris
    nix-output-monitor
    unstable.invidtui
    xclip
    glances
    keepassxc
    hyfetch
    starship
    #spotify
    #spotifywm
    #spicetify-cli
    #spotdl
    gnome.file-roller
    nano
    freshfetch
    bruno
    nanorc
    kitty-themes
    vscode
    xed-editor
    gnome.ghex
    krita
    ffmpeg
    tmux
    unstable.jetbrains.rust-rover
    unstable.jetbrains.rider
    unstable.jetbrains.idea-ultimate
    unstable.jetbrains.clion
    unstable.jetbrains.pycharm-professional
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
          { command = "${openrgb.out}/bin/openrgb --startminimized --profile \"Trans-Purple\""; always = false; notification = false; }
          { command = "${dunst.out}/bin/dunst"; always = false; notification = false; }
          { command = "${kitti3.out}/bin/kitti3 -n caterwaul -p CC -s 0.4 0.4"; always = true; notification = false; }
          { command = "${flameshot.out}/bin/flameshot"; always = false; notification = false; }
          { command = "${networkmanagerapplet.out}/bin/nm-applet"; always = false; notification = false; }
          { command = "${sirikali.out}/bin/sirikali"; always = false; notification = false; }
          { command = "${keepassxc.out}/bin/keepassxc"; always = false; notification = false; }
          { command = "${qbittorrent.out}/bin/qbittorrent"; always = false; notification = false; }
          { command = "${blueman.out}/bin/blueman-applet"; always = false; notification = false; }
          { command = "${sswitcher.out}/bin/sswitcher"; always = false; notification = false; }
#          { command = "${steam.out}/bin/steam"; always = false; notification = false; }
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

      # limits recursive functions, see 'man bash'
      [[ -z "$FUNCNEST" ]] && export FUNCNEST=100

      ## Use the up and down arrow keys for finding a command in history
      ## (you can write some initial letters of the command first).
      bind '"\e[A":history-search-backward'
      bind '"\e[B":history-search-forward'

      alias ls='ls -lav --color=auto --ignore=..'
      alias l='ls -lav --color=auto --ignore=.. | grep '
      alias pacdiff=eos-pacdiff
      alias invidtui="invidtui --close-instances"
      alias schp="xclip <~/Documents/school_pass.zip"
      alias miniarch="~/connect aurora nova711.asuscomm.com"
      alias update-clean="sys-switch && switch && home-clean && sys-clean"

      alias nix-shell="nix-shell --log-format bar-with-logs"
      alias nix-build="nix-build --log-format bar-with-logs"
      alias nix-store="nix-store --log-format bar-with-logs"
      alias nixos-rebuild="nixos-rebuild --log-format bar-with-logs"
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;
      scan_timeout = 10;

      format = lib.concatStrings [
        "$directory"
        "$sudo"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$nix_shell"
        "$dotnet"
        "$rust"
        "$python"
        "$fill"
        "$memory_usage"
        "$battery"
        "$time"
        "$line_break"
        "$character"
      ];

      directory = { disabled = false; format = "[$path]($style)[$read_only]($read_only_style)"; };
      sudo = { disabled = false; format = " as [sudo]($style)"; style = "bold red"; };
      time = { disabled = false; format = "[ \\[ $time \\]]($style)"; time_format = "%T"; utc_time_offset = "-4"; };
      battery = { disabled = false; display = [ { threshold = 75; } ]; };
      memory_usage = { disabled = false; format = " [$ram RAM( | $swap SWAP)]($style)"; threshold = 50; };
      nix_shell = { disabled = false; format = " in [$state $name]($style)"; };
      git_branch = { disabled = false; format = " on [$symbol$branch(:$remote_branch)]($style)"; };
      git_commit = { disabled = false; format = "[ \\($hash$tag\\)]($style)"; };
      git_state = { disabled = false; format = "\\([ $state($progress_current/$progress_total)]($style)\\)"; };
      git_metrics = { disabled = false; format = "([ +$added]($added_style))([ -$deleted]($deleted_style))"; };
      git_status = { disabled = false; format = "([ \\[$all_status$ahead_behind\\]]($style))"; };
      dotnet = { disabled = false; format = " via [$symbol$version]($style)"; version_format = "v$major"; };
      rust = { disabled = false; format = " via [$symbol$version]($style)"; };
      python = { disabled = false; format = " via [$symbol$pyenv_prefix $version \\($virtualenv\\)]($style)"; };
      fill = { symbol = " "; };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    includes = [
      {
        contents = {
          commit.gpgsign = true;
          gpg.format = "ssh";

          user = {
            name = "Aurora Dawn";
            email = "131844170+StellarWitch7@users.noreply.github.com";
            signingKey = "key::ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDa9q/hF/Ign0phm5I1ZZ+ZX3Xe2yk8OqNYOX4R8gWpMR6CctkrIoBAzriaTk4GAUpy1A0C450uAMiveEcuyMBZrO+eP9gHbSvauFcqkeA/xtm5rqyCKyFAoUpUcKfHQ/ZQWhCIA5taC9WbqPblLXIunZOgEaxRuc922GCMsp+p33dR1sAVrq2QyYQAZZEk53M1rOT1gtDCUyGnsdY7Huiuxlum+oeUWRGogkViww2FfGO4uGj0qbOHUKL5mrFewXZ3VqlIqxAh6p7cqEZV8jgGfprI4Tv6QRaCKKEGfRjZ66dIolRIDtZwoxyAxUf716ZqMHNCGhNRtnUYClDMIFh76K6EAAtuyCEmXoMOSKVrfzLVfXQD1K/DaqDnOjhz5digl1l8elLUdBmpa050u9/3j4XC8wOGljqJRNfsZQg112A/BVjoR+Iz+VAWHvcxRnK7+ZpEzX3CN14PAYsnNcZ4uXjsFeJDbPkUZFIt1y/3vdbahPKk7239wnDNiy4cjr8xsTeeMgeYHR6AY+NRRhpBADLpSaz9YI86xLcQXqM8GieWTWAHMLQfKda3c7Bjw8e6xgBMWxkNfPMBKb6bVxWEnb5gFarXLXLTLkKFf9LY02mNA1wdjP3IkbXHc1T7OXPIl9JIBvuEnCPq9TS4JgRPhtLUGKzlsj1knWUWOyVIGw== 131844170+StellarWitch7@users.noreply.github.com";
          };
        };
      }
    ];
  };

  services.ssh-agent = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

  services.polybar = {
    enable = true;
    catppuccin.enable = true;

    package = pkgs.polybarFull;

    config = "${hconf}/polybar/config.ini";

    script = ''
      ${pbar-start.out}/bin/launch
    '';
  };

  services.dunst = {
    enable = true;
    catppuccin.enable = true;
  };

  systemd.user.services = {
    clean = {
      Unit = {
        Description = "Clean user Nix store.";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "${aurpkgs.easy-nixos.out}/bin/home-clean";
      };
    };
  };

  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
  };

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
  };

  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
      icon.enable = true;
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

    PATH = "$PATH:$HOME/.bin:$GAMES:$APPS:$HOME/.cargo/bin:$HOME/.nix-profile/bin:$HOME/.spicetify:/var/lib/snapd/snap/bin:$HOME/.dotnet/tools";

    EDITOR = "${editor}";
    BROWSER = "${browser}";

    HISTCONTROL = "ignoredups:ignorespace";
    HISTTIMEFORMAT = "[%Y/%m/%d @ %H:%M:%S] ";

    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";

    QT_QPA_PLATFORMTHEME = "qt5ct";

    ALL_NULL = "1>/dev/null 2>&1";
    OUT_NULL = "1>/dev/null";
    ERR_NULL = "2>/dev/null";
  };
}
