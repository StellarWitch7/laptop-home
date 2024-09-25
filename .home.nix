{ config, lib, pkgs, ... }:

let
  aurpkgs = import (builtins.fetchGit {
    url = "https://github.com/StellarWitch7/nurpkgs";
  }) { };
  editor = "nvim";
  browser = "firefox";
  terminal = "${pkgs.kitty.out}/bin/kitty";
  lock = "${i3-lock.out}/bin/i3-lock-blurred";
  screenshotter = "${pkgs.flameshot.out}/bin/flameshot";
  screenshot-gui = "${screenshotter} gui";
  screenshot-full = "${screenshotter} full";
  sswitcher = pkgs.writeShellScriptBin "sswitcher" ''
    exec nix-shell -p indicator-sound-switcher --run indicator-sound-switcher
  '';
  pbar-start = pkgs.writeShellScriptBin "launch" ''
    ${pkgs.polybarFull.out}/bin/polybar-msg cmd quit
    exec ${pkgs.polybarFull.out}/bin/polybar
  '';
  i3-lock = pkgs.writeShellScriptBin "i3-lock-blurred" ''
    img=/tmp/i3lock.png

    # suspend message display
    pkill -u "$USER" -USR1 dunst
    sleep 1

    # take screenshot
    ${pkgs.scrot.out}/bin/scrot -o $img

    # blur screenshot
    ${pkgs.imagemagick.out}/bin/convert $img -scale 10% -scale 1000% $img

    # lock the screen
    ${pkgs.i3lock.out}/bin/i3lock -n -i $img

    # resume message display
    pkill -u "$USER" -USR2 dunst
  '';
  name = "aur";
  dir = "/home/${name}";
  hconf = /${dir}/.hconf;
in {
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

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
  };

  imports = [
    /etc/nixos/default-home.nix
    "${builtins.fetchGit {
      url = "https://github.com/catppuccin/nix";
    }}/modules/home-manager"
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
    })).homeManagerModules.nixvim
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    sswitcher
  ] ++ (with aurpkgs; [
    git-nixed
    vault
    bar
    ImageSorter
  ]) ++ (with pkgs; [
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
    (writeShellScriptBin "remindme" ''
      time="$1"
      text="$2"
      
      echo "notify-send --category reminder 'Reminder' '$text'" | at now + "$time"
    '')
    unstable.vesktop
    unstable.zed-editor
    octave
    xplr
    firefox
    handbrake
    vlc
    audacity
    gitnr
    calibre
    zathura
    simplescreenrecorder
    freetube
    firefox
    libreoffice
    hunspell
    tree
    aseprite
    blockbench
    git
    gitAndTools.gh
    hunspellDicts.en_GB-ise
    yt-dlp
    bottom
    sirikali
    flameshot
    qbittorrent
    openrgb
    rclone
    bespokesynth
    picom
    dunst
    blueman
    kitty
    linux-wifi-hotspot
    feh
    prismlauncher
    lxqt.lxqt-policykit
    autorandr
    unzip
    obs-studio
    with-shell
    networkmanagerapplet
    mindustry-server
    pavucontrol
    nix-output-monitor
    unstable.invidtui
    xclip
    glances
    keepassxc
    hyfetch
    gnome.file-roller
    bruno
    kitty-themes
    xed-editor
    gnome.ghex
    krita
    ffmpeg
    #obsidian
    #vscode
    #unstable.jetbrains.rust-rover
    #unstable.jetbrains.rider
    #unstable.jetbrains.idea-ultimate
    #unstable.jetbrains.clion
    #unstable.jetbrains.pycharm-professional
  ]);

  xsession = {
    enable = true;
    numlock.enable = true;

    windowManager.i3 = import (hconf + /i3) {
      inherit lib pkgs dir hconf lock terminal browser sswitcher pbar-start screenshot-full screenshot-gui;
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
      alias update-clean="home-clean && sys-clean && sys-switch && switch"

      alias nix-shell="nix-shell --log-format bar-with-logs"
      alias nix-build="nix-build --log-format bar-with-logs"
      alias nix-store="nix-store --log-format bar-with-logs"
      alias nixos-rebuild="nixos-rebuild --log-format bar-with-logs"
    '';
  };

  programs.starship = import (hconf + /starship) {
    inherit lib;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
    inherit terminal;
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

  programs.nixvim = import (hconf + /neovim) {
    inherit config pkgs dir;
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
    config = hconf + /polybar/config.ini;
    script = "";
  };

  services.dunst = {
    enable = true;
    catppuccin.enable = true;

    settings = {
      remindme = {
        category = "reminder";
        background = "#333333";
        foreground = "#ff7f7f";
        timeout = 0;
      };
    };
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
  };
}
