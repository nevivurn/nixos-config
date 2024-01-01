{ inputs, lib, pkgs, ... }:

with inputs;

{
  imports = [
    self.homeModules.sway
  ];

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
      makeShader = shaders: lib.concatMapStringsSep ":" (s: "~~/shaders/${s}") shaders;
      makeShaderHQ = shaders: makeShader
        (builtins.map (builtins.replaceStrings [ "_M." "_S." ] [ "_VL." "_M." ]) shaders);
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
        dither = "error-diffusion";

        scale = "ewa_lanczos";
        cscale = "ewa_lanczos";
        scale-blur = 0.981251;
        cscale-blur = 0.981251;
      };
      bindings = {
        "D" = "cycle deband";
        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';

        "CTRL+1" = ''no-osd change-list glsl-shaders set "${makeShader a4k_A}"; show-text "Anime4K: Mode A"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${makeShader a4k_B}"; show-text "Anime4K: Mode B"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${makeShader a4k_C}"; show-text "Anime4K: Mode C"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${makeShader a4k_AA}"; show-text "Anime4K: Mode AA"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${makeShader a4k_BB}"; show-text "Anime4K: Mode BB"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${makeShader a4k_CA}"; show-text "Anime4K: Mode CA"'';
      };
    };

  xdg.configFile."mpv/shaders".source = pkgs.fetchzip {
    name = "Anime4K";
    url = "https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip";
    hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
    stripRoot = false;
  };

  home.packages = with pkgs; [
    picocom
  ];
}
