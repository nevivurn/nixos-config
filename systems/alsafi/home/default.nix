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
      # Swap caps/ctrl only on the built-in laptop keyboard
      "1:1:AT_Translated_Set_2_keyboard" = {
        xkb_options = "ctrl:swapcaps,korean:ralt_hangul";
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
      settings.status_idle = "&#xf240;";
    };
  };

  # We have a real GPU
  programs.mpv =
    let
      a4k_A = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Restore_CNN_M.glsl"
        "Anime4K_Upscale_CNN_x2_M.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      a4k_B = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Restore_CNN_Soft_M.glsl"
        "Anime4K_Upscale_CNN_x2_M.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      a4k_C = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Upscale_Denoise_CNN_x2_M.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      a4k_AA = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Restore_CNN_M.glsl"
        "Anime4K_Upscale_CNN_x2_M.glsl"
        "Anime4K_Restore_CNN_S.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      a4k_BB = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Restore_CNN_Soft_M.glsl"
        "Anime4K_Upscale_CNN_x2_M.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Restore_CNN_Soft_S.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      a4k_CA = [
        "Anime4K_Clamp_Highlights.glsl"
        "Anime4K_Upscale_Denoise_CNN_x2_M.glsl"
        "Anime4K_AutoDownscalePre_x2.glsl"
        "Anime4K_AutoDownscalePre_x4.glsl"
        "Anime4K_Restore_CNN_S.glsl"
        "Anime4K_Upscale_CNN_x2_S.glsl"
      ];
      fsr = [
        "FSR.glsl"
        "SSimDownscaler.glsl"
        "KrigBilateral.glsl"
      ];
      makeShader = shaders: lib.concatMapStringsSep ":" (s: "~~/shaders/${s}") shaders;
      makeShaderHQ =
        shaders:
        makeShader (
          builtins.map (builtins.replaceStrings
            [
              "_M."
              "_S."
            ]
            [
              "_VL."
              "_M."
            ]
          ) shaders
        );
    in
    {
      config = {
        profile = "gpu-hq";
        vo = "gpu-next";
        gpu-api = "vulkan";

        deband = false;
        deband-iterations = 4;
        deband-threshold = 48;
        deband-range = 24;
        deband-grain = 16;

        dither-depth = "auto";
        dither = "fruit";

        scale = "ewa_lanczos";
        cscale = "ewa_lanczos";
        scale-blur = 0.981251;
        cscale-blur = 0.981251;

        tone-mapping = "hable";
        hdr-compute-peak = true;
      };
      bindings = {
        "D" = "cycle deband";
        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';

        "CTRL+1" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_A}"; show-text "Anime4K: Mode A"'';
        "CTRL+2" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_B}"; show-text "Anime4K: Mode B"'';
        "CTRL+3" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_C}"; show-text "Anime4K: Mode C"'';
        "CTRL+4" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_AA}"; show-text "Anime4K: Mode AA"'';
        "CTRL+5" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_BB}"; show-text "Anime4K: Mode BB"'';
        "CTRL+6" =
          ''no-osd change-list glsl-shaders set "${makeShaderHQ a4k_CA}"; show-text "Anime4K: Mode CA"'';
        "CTRL+7" = ''no-osd change-list glsl-shaders set "${makeShader fsr}"; show-text "FSR"'';
      };
    };

  xdg.configFile."mpv/shaders".source =
    let
      anime4k = pkgs.fetchzip {
        name = "Anime4K";
        url = "https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip";
        hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
        stripRoot = false;
      };
      fsr = pkgs.fetchgit {
        name = "FSR";
        url = "https://gist.github.com/agyild/82219c545228d70c5604f865ce0b0ce5";
        rev = "2623d743b9c23f500ba086f05b385dcb1557e15d";
        hash = "sha256-eNK+DOcFCFKbDBfjKjZwBtf4JKoN4UmwCEigeLoWBy0=";
      };
      # Do I have *any* idea what I'm doing? Of course not.
      SSimDownscaler = pkgs.fetchgit {
        name = "SSimDownscaler";
        url = "https://gist.github.com/igv/36508af3ffc84410fe39761d6969be10";
        rev = "575d13567bbe3caa778310bd3b2a4c516c445039";
        hash = "sha256-1XtyEllDYCccTopQAmzX64crbCKA0e7seoagqyH7yxI=";
      };
      KrigBilateral = pkgs.fetchgit {
        name = "KrigBilateral";
        url = "https://gist.github.com/igv/a015fc885d5c22e6891820ad89555637";
        rev = "038064821c5f768dfc6c00261535018d5932cdd5";
        hash = "sha256-xBtbSxUyRb0kC3V+Ge/kKhtTUTCQv9MMDY6UakNrfCw=";
      };
    in
    pkgs.symlinkJoin {
      name = "mpv-shaders";
      paths = [
        anime4k
        fsr
        SSimDownscaler
        KrigBilateral
      ];
    };

  programs.ssh.matchBlocks."*".certificateFile = "${./../cert.pub}";

  home.packages = with pkgs; [ pkgsUnstable.claude-code ];

  home.persistence."/persist/cache" = {
    files = [ ".claude.json" ];
    directories = [ ".claude" ];
  };
}
