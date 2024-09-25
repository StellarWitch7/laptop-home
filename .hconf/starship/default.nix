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

    #TODO: AAAAAAAAAAA USE mkSetting PLEASE DEAR GODS
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
}
