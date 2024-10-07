{ lib, pkgs }:

{
  enable = true;

  mimeApps = {
    enable = true;

    defaultApplications = let
      archive-manager = "org.gnome.FileRoller.desktop";
      file-manager = "thunar.desktop";
      vlc = "vlc.desktop";
    in {
      "inode/directory" = file-manager;
      "application/gzip" = archive-manager;
      "application/x-gzip" = archive-manager;
      "application/zip" = archive-manager;
      "application/x-zip-compressed" = archive-manager;
      "application/x-tar" = archive-manager;
      "application/vnd.rar" = archive-manager;
      "application/x-7z-compressed" = archive-manager;
      "video/dv" = vlc;
      "video/mpeg" = vlc;
      "video/x-mpeg" = vlc;
      "video/msvideo" = vlc;
      "video/quicktime" = vlc;
      "video/x-anim" = vlc;
      "video/x-avi" = vlc;
      "video/x-ms-asf" = vlc;
      "video/x-ms-wmv" = vlc;
      "video/x-msvideo" = vlc;
      "video/x-nsv" = vlc;
      "video/x-flc" = vlc;
      "video/x-fli" = vlc;
      "application/ogg" = vlc;
      "application/x-ogg" = vlc;
      "application/x-matroska" = vlc;
      "audio/x-mp3;audio/x-mpeg" = vlc;
      "audio/mpeg;audio/x-wav" = vlc;
      "audio/x-mpegurl" = vlc;
      "audio/x-scpls" = vlc;
      "audio/x-m4a" = vlc;
      "audio/x-ms-asf" = vlc;
      "audio/x-ms-asx" = vlc;
      "audio/x-ms-wax" = vlc;
      "application/vnd.rn-realmedia" = vlc;
      "audio/x-real-audio" = vlc;
      "audio/x-pn-realaudio" = vlc;
      "application/x-flac" = vlc;
      "audio/x-flac" = vlc;
      "application/x-shockwave-flash" = vlc;
      "misc/ultravox;audio/vnd.rn-realaudio" = vlc;
      "audio/x-pn-aiff;audio/x-pn-au" = vlc;
      "audio/x-pn-wav" = vlc;
      "audio/x-pn-windows-acm" = vlc;
      "image/vnd.rn-realpix" = vlc;
      "video/vnd.rn-realvideo" = vlc;
      "audio/x-pn-realaudio-plugin" = vlc;
      "application/x-extension-mp4" = vlc;
      "audio/mp4;video/mp4" = vlc;
      "video/mp4v-es" = vlc;
      "x-content/video-vcd" = vlc;
      "x-content/video-svcd" = vlc;
      "x-content/video-dvd" = vlc;
      "x-content/audio-cdda" = vlc;
      "x-content/audio-player" = vlc;
      "video/x-flv" = vlc;
    };
  };
}
