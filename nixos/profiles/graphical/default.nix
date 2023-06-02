{ pkgs, ... }:

{
  fonts.enableDefaultFonts = true;
  hardware.opengl.enable = true;

  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  xdg.portal.wlr.enable = true;

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  hardware.bluetooth.enable = true;
}
