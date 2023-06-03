{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.programs.jellyfin-mpv-shim;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.jellyfin-mpv-shim = {
    enable = mkEnableOption "jellyfin-mpv-shim";
    package = mkOption {
      type = with types; package;
      default = pkgs.jellyfin-mpv-shim;
    };
    config = mkOption {
      type = with types; nullOr jsonFormat.type;
      default = { };
    };
    useMpvConfig = mkOption {
      type = with types; bool;
      default = false;
    };
  };

  config = mkIf cfg.enable
    {
      home.packages = [ cfg.package ];
      xdg.configFile."jellyfin-mpv-shim/conf.json" = mkIf (cfg.config != null)
        { source = jsonFormat.generate "jellyfin-mpv-shim-conf.json" cfg.config; };

      systemd.user.tmpfiles.rules = mkIf cfg.useMpvConfig [
        "L+ %h/.config/jellyfin-mpv-shim/mpv.conf - - - - ../mpv/mpv.conf"
        "L+ %h/.config/jellyfin-mpv-shim/input.conf - - - - ../mpv/input.conf"
      ];
    };
}
