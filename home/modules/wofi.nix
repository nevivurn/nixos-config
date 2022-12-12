{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.programs.wofi;
in
{
  options.programs.wofi = {
    enable = mkEnableOption "wofi";
    package = mkOption {
      type = types.package;
      default = pkgs.wofi;
    };
    config = mkOption {
      type = with types; nullOr (attrsOf (either str (either bool int)));
      default = null;
    };
    style = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."wofi/config" = mkIf (cfg.config != null)
      { text = generators.toKeyValue { } cfg.config; };
    xdg.configFile."wofi/style.css" = mkIf (cfg.style != null)
      { text = cfg.style; };
  };
}
