{ pkgs }:

let
  src = pkgs.fetchFromGitHub {
    owner = "StellarWitch7";
    repo = "polybar-mic-volume";
    rev = "5acd3b2f2db09eaa14caa91cda856bbaddaca450";
    hash = "sha256-QexNYNwsmogG1oIJFbeGn36bKibBREPSDWgBoelQ4w0=";
  };
  script = (pkgs.writeShellScriptBin "polybar-mic" ''
    env PATH=$PATH:${pkgs.pulseaudio.out}/bin ${pkgs.bash.out}/bin/bash ${src}/mic-volume/mic-volume.sh "$@"
  '').out + /bin/polybar-mic;
in {
  enable = true;
  catppuccin.enable = true;
  package = pkgs.polybarFull;
  script = "";
  config = pkgs.writeText "config.ini" ((builtins.readFile ./config.ini) + ''
    [bar/primary]
    modules-left = whoami xkeyboard cpu memory xworkspaces
    modules-center = systray
    modules-right = mic-volume pulseaudio wlan battery date
    
    [module/mic-volume]
    type = custom/script
    interval = 0.1
    exec = ${script} show-vol

    ; Control actions (using pactl)
    click-left = ${script} mute-vol
    scroll-up = ${script} inc-vol
    scroll-down = ${script} dec-vol
  '');
}
