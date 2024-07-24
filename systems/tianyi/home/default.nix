{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.self.homeModules.sway ];

  wayland.windowManager.sway.config = {
    keybindings = {
      "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
      "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
      "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set +5%";
      "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";
    };
    input = {
      "type:keyboard" = {
        xkb_options = lib.mkForce "ctrl:swapcaps,korean:ralt_hangul";
      };
      "type:touch" = {
        events = "disabled";
      };
      "type:touchpad" = {
        tap = "enabled";
        dwt = "enabled";
      };
    };
  };
  programs.i3status.modules = {
    "wireless wlan0" = {
      position = 4;
      settings.format_up = "&#xf1eb; %essid";
      settings.format_down = "&#xf1eb;";
    };
    "battery 0" = {
      position = 5;
      settings.format = "%status %percentage";
      settings.status_chr = "&#xf0e7;";
      settings.status_bat = "&#xf241;";
      settings.status_unk = "&#x3f;";
      settings.status_full = "&#xf240;";
    };
  };
}
