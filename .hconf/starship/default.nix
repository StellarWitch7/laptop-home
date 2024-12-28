{ lib }:

let
  mkSetting = enabled: format: extra: (
    if (isNull format)
    then { }
    else { inherit format; }
  ) // {
    disabled = !enabled;
  } // extra;
in {
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

    directory = mkSetting true "[$path]($style)[$read_only]($read_only_style)" { };
    sudo = mkSetting true " as [sudo]($style)" { style = "bold red"; };
    time = mkSetting true "[ \\[ $time \\]]($style)" { time_format = "%T"; utc_time_offset = "-4"; };
    battery = mkSetting true null { display = [ { threshold = 75; } ]; };
    memory_usage = mkSetting true " [$ram RAM( | $swap SWAP)]($style)" { threshold = 50; };
    nix_shell = mkSetting true " in [$state $name]($style)" { };
    git_branch = mkSetting true " on [$symbol$branch(:$remote_branch)]($style)" { };
    git_commit = mkSetting true "[ \\($hash$tag\\)]($style)" { };
    git_state = mkSetting true "\\([ $state($progress_current/$progress_total)]($style)\\)" { };
    git_metrics = mkSetting true "([ +$added]($added_style))([ -$deleted]($deleted_style))" { };
    git_status = mkSetting true "([ \\[$all_status$ahead_behind\\]]($style))" { };
    dotnet = mkSetting true " via [$symbol$version]($style)" { version_format = "v$major"; };
    rust = mkSetting true " via [$symbol$version]($style)" { };
    python = mkSetting true " via [$symbol$pyenv_prefix $version \\($virtualenv\\)]($style)" { };
    fill = { symbol = " "; };
  };
}
