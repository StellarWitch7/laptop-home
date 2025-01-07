{ config, lib, pkgs, ... }:

let
  aurpkgs = import (builtins.fetchGit {
    url = "https://github.com/StellarWitch7/nurpkgs";
  }) { inherit pkgs; };
  pinnedPkgs = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c71ad5c34d51dcbda4c15f44ea4e4aa6bb6ac1e9";
    hash = "sha256-fYNXgpu1AEeLyd3fQt4Ym0tcVP7cdJ8wRoqJ+CtTRyY=";
  }) { config.allowUnfree = true; };
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
in rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = name;
  home.homeDirectory = dir;

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    kitty.enable = true;
  };

  imports = [
    /etc/nixos/default-home.nix
    (builtins.fetchGit {
      url = "https://github.com/catppuccin/nix";
    } + /modules/home-manager)
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-24.11";
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
    #ImageSorter # broken
  ]) ++ (with pinnedPkgs; [
    aseprite
    krita
    ffmpeg
  ]) ++ (with pkgs; [
    (writeShellScriptBin "recon-gdrive" ''
      ${rclone.out}/bin/rclone config reconnect AuraGDrive:
      nohup ${rclone.out}/bin/rclone mount AuraGDrive: ~/CloudData/AuraGDrive &
    '')
    # (writeShellScriptBin "cs-fmt" ''
    #   nix-shell -p dotnet-sdk csharpier --run "dotnet-csharpier $@"
    # '')
    (writeShellScriptBin "hotspot" ''
      pkexec --user root ${linux-wifi-hotspot.out}/bin/create_ap wlan0 wlan0 "solanix" "$1" --mkconfig /etc/create_ap.conf -g 1.1.1.1
    '')
    (writeShellScriptBin "hotspot-gui" ''
      exec ${linux-wifi-hotspot.out}/bin/wihotspot-gui "$@"
    '')
    (writeShellScriptBin "remindme" ''
      time="$1"
      text="$2"
      
      echo "notify-send --category reminder 'Reminder' '$text'" | at now + "$time"
    '')
    (writeShellScriptBin "litterbox" ''
      link=$(curl -F "reqtype=fileupload" -F "time=72h" -F "fileToUpload=@$1" https://litterbox.catbox.moe/resources/internals/api.php)
      echo "Copying $link to clipboard using xclip"
      echo $link | xclip -selection CLIPBOARD
    '')
    (writeShellScriptBin "rec-sed" ''
      find ./ -type f -exec sed -i -e "$1" {} \;
    '')
    (writeShellScriptBin "mcdev-open-all" ''
      nvim $(find src/main/java -type f) $(find src/client/java -type f)
    '')
    unstable.vesktop
    octave
    firefox
    handbrake
    vlc
    audacity
    gitnr
    calibre
    zathura
    r2modman
    simplescreenrecorder
    freetube
    heroic
    firefox
    libreoffice
    lazygit
    hunspell
    tree
    blockbench
    thunderbird
    git
    gitAndTools.gh
    hunspellDicts.en_GB-ise
    hunspellDicts.tok
    airshipper
    fzf
    itch
    yt-dlp
    osu-lazer-bin
    the-powder-toy
    celeste64
    bottom
    sirikali
    flameshot
    qbittorrent
    pandoc
    openrgb
    rclone
    bespokesynth
    picom
    dunst
    blueman
    linux-wifi-hotspot
    prismlauncher
    lxqt.lxqt-policykit
    autorandr
    obs-studio
    with-shell
    papirus-icon-theme
    networkmanagerapplet
    mindustry-server
    pavucontrol
    nix-output-monitor
    invidtui
    xclip
    glances
    keepassxc
    hyfetch
    bruno
    xdragon
    dua
    fzf
    trash-cli
    pistol
    ghostie
    ouch
    ventoy-full
    obsidian
    #unstable.spotube
    #unstable.zed-editor
  ]) ++ programs.rofi.plugins;

  xsession = {
    enable = true;
    numlock.enable = true;

    windowManager.i3 = import (hconf + /i3) {
      inherit lib config pkgs aurpkgs dir hconf lock terminal browser sswitcher pbar-start screenshot-full screenshot-gui;
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
      alias school="xrandr --output HDMI-1-1 --primary --auto --output eDP-1 --off"

      alias nix-shell="nix-shell --log-format bar-with-logs"
      alias nix-build="nix-build --log-format bar-with-logs"
      alias nix-store="nix-store --log-format bar-with-logs"
      alias nixos-rebuild="nixos-rebuild --log-format bar-with-logs"
      alias nix="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

      alias xcd="cd \$(xplr)"
      alias i2pbit="qbittorrent --configuration=I2P"
    '';
  };

  programs.kitty = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
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

    plugins = with pkgs; [
      rofi-calc
      rofi-bluetooth
      rofi-power-menu
      rofi-file-browser
      keepmenu
    ];
  };

  programs.git = {
    enable = true;
    userName = "Aurora Dawn";
    userEmail = "131844170+StellarWitch7@users.noreply.github.com";

    signing = {
      signByDefault = true;
      key = "key::ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDa9q/hF/Ign0phm5I1ZZ+ZX3Xe2yk8OqNYOX4R8gWpMR6CctkrIoBAzriaTk4GAUpy1A0C450uAMiveEcuyMBZrO+eP9gHbSvauFcqkeA/xtm5rqyCKyFAoUpUcKfHQ/ZQWhCIA5taC9WbqPblLXIunZOgEaxRuc922GCMsp+p33dR1sAVrq2QyYQAZZEk53M1rOT1gtDCUyGnsdY7Huiuxlum+oeUWRGogkViww2FfGO4uGj0qbOHUKL5mrFewXZ3VqlIqxAh6p7cqEZV8jgGfprI4Tv6QRaCKKEGfRjZ66dIolRIDtZwoxyAxUf716ZqMHNCGhNRtnUYClDMIFh76K6EAAtuyCEmXoMOSKVrfzLVfXQD1K/DaqDnOjhz5digl1l8elLUdBmpa050u9/3j4XC8wOGljqJRNfsZQg112A/BVjoR+Iz+VAWHvcxRnK7+ZpEzX3CN14PAYsnNcZ4uXjsFeJDbPkUZFIt1y/3vdbahPKk7239wnDNiy4cjr8xsTeeMgeYHR6AY+NRRhpBADLpSaz9YI86xLcQXqM8GieWTWAHMLQfKda3c7Bjw8e6xgBMWxkNfPMBKb6bVxWEnb5gFarXLXLTLkKFf9LY02mNA1wdjP3IkbXHc1T7OXPIl9JIBvuEnCPq9TS4JgRPhtLUGKzlsj1knWUWOyVIGw== 131844170+StellarWitch7@users.noreply.github.com";
    };

    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      init.defaultBranch = "main";
    };
  };

  programs.xplr = {
    enable = true;

    plugins = with pkgs; {
      zoxide = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "zoxide.xplr";
        rev = "e50fd35db5c05e750a74c8f54761922464c1ad5f";
        hash = "sha256-ZiOupn9Vq/czXI3JHvXUlAvAFdXrwoO3NqjjiCZXRnY=";
      };

      trash-cli = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "trash-cli.xplr";
        rev = "2c5c8c64ec88c038e2075db3b1c123655dc446fa";
        hash = "sha256-Yb6meF5TTVAL7JugPH/znvHhn588pF5g1luFW8YYA7U=";
      };

      dua-cli = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "dua-cli.xplr";
        rev = "66ccf983fab7f67d6b00adc0365a2b26550e7f81";
        hash = "sha256-XDhXaS8GuY3fuiSEL0WcLFilZ72emmjTVi07kv5c8n8=";
      };

      dragon = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "dragon.xplr";
        rev = "5fbddcb33f7d75a5abd12d27223ac55589863335";
        hash = "sha256-FJbyu5kK78XiTJl0NNXcI0KPOdXOPwpbBCWPUEpu5zA=";
      };

      fzf = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "fzf.xplr";
        rev = "c8991f92946a7c8177d7f82ed939d845746ebaf5";
        hash = "sha256-dpnta67p3fYEO3/GdvFlqzdyiMaJ9WbsnNmoIRHweMI=";
      };

      xclip = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "xclip.xplr";
        rev = "ddbcce2a255537ce8e3680575bbe964b49d05979";
        hash = "sha256-9WYT52H6vfqTGos57/Um/UqVCkteTAbnUSQ5xDb+JrY=";
      };

      ouch = fetchFromGitHub {
        owner = "dtomvan";
        repo = "ouch.xplr";
        rev = "375edf19ff3e0286bd7a101b9e4dd24fa5abaeb8";
        hash = "sha256-YGFQKzIYIlL+UW2Nel2Tw7WC3MESaVbWYlpj5o2FfLs=";
      };

      nuke = fetchFromGitHub {
        owner = "Junker";
        repo = "nuke.xplr";
        rev = "f83a7ed58a7212771b15fbf1fdfb0a07b23c81e9";
        hash = "sha256-k/yre9SYNPYBM2W1DPpL6Ypt3w3EMO9dznHwa+fw/n0=";
      };
    };

    extraConfig = ''
      require("zoxide").setup({
        bin = "zoxide",
        mode = "default",
        key = "Z",
      })

      require("trash-cli").setup({
        -- Trash file(s)
        trash_bin = "trash-put",
        trash_mode = "delete",
        trash_key = "d",

        -- Empty trash
        empty_bin = "trash-empty",
        empty_mode = "delete",
        empty_key = "E",

        -- Interactive selector
        trash_list_bin = "trash-list",
        trash_list_selector = "fzf -m | cut -d' ' -f3-",

        -- Restore file(s)
        restore_bin = "trash-restore",

        -- Restore files deleted from $PWD only
        restore_mode = "delete",
        restore_key = "r",

        -- Restore files deleted globally
        global_restore_mode = "delete",
        global_restore_key = "R",
      })
      
      require("dua-cli").setup({
        mode = "action",
        key = "D",
      })
      
      require("dragon").setup({
        mode = "selection_ops",
        key = "D",
        drag_args = "",
        drop_args = "",
        keep_selection = false,
        bin = "dragon",
      })

      require("fzf").setup({
        mode = "default",
        key = "ctrl-f",
        bin = "fzf",
        args = "--preview 'pistol {}'",
        recursive = true,  -- If true, search all files under $PWD
        enter_dir = true,  -- Enter if the result is directory
      })

      require("xclip").setup{
        copy_command = "xclip-copyfile",
        copy_paths_command = "xclip -sel clip",
        paste_command = "xclip-pastefile",
        keep_selection = false,
      }

      require("ouch").setup{
        mode = "action",
        key = "o",
      }

      require("nuke").setup()
    '';
  };

  programs.nixvim = import (hconf + /neovim) {
    inherit config lib pkgs;
  };

  services.ssh-agent = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

  services.polybar = import (hconf + /polybar) {
    inherit pkgs;
  };

  services.dunst = {
    enable = true;
    catppuccin.enable = true;
    configFile = "${dir}/.config/dunst/dunstrc";

    settings = {
      global = {
        ignore_dbusclose = true;
      };

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

    # catppuccin = {
    #   enable = true;
    #   icon.enable = true;
    # };

    theme = {
      name = "Catppuccin-GTK-Purple-Dark";
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "purple" ];
      };
    };

    cursorTheme = {
      name = "Future-cyan-cursors";
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme=true
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    style.name = "gtk2";
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  xdg = import (hconf + /xdg) {
    inherit lib pkgs;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = let
    mkConf = path: source: {
      ".config/${path}" = {
        inherit source;
      };
    };
    toml = config: {
      generator = pkgs.formats.toml {  };
      inherit config;
    };
    ini = config: {
      generator = pkgs.formats.ini { };
      inherit config;
    };
  in {
    # ".config/gradle/gradle.properties".source = /path/to/file;
    # ".config/gradle/gradle.properties".text = ''example text'';
  } // ((a: lib.attrsets.concatMapAttrs (k: { generator, config, ... }: mkConf k (generator.generate (builtins.baseNameOf k) config)) a) {
    "proton.conf" = toml rec {
      data = "${dir}/.proton";
      steam = "${dir}/.steam/root";
      common = "${steam}/steamapps/common";
    };

    "keepmenu/config.ini" = ini {
      dmenu = {
        dmenu_command = "rofi -i";
      };

      dmenu_passphrase = {
        obscure = true;
      };

      database = let
        entries = [
          {
            database = "~/KPXC/data.kdbx";
            keyfile = "";
          }
        ];
      in lib.lists.foldr (a: b: a // b) { } (lib.lists.imap1 (i: { database, keyfile, ... }: { "database_${builtins.toString i}" = database; "keyfile_${builtins.toString i}" = keyfile; }) entries) // {
        pw_cache_period_min = 20;
        autotype_default = "{USERNAME}{TAB}{PASSWORD}{ENTER}";
      };
    };
  });

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

    QT_QPA_PLATFORMTHEME = "qt5ct";

    _ZO_RESOLVE_SYMLINKS = 1;
    _ZO_ECHO = 1;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
