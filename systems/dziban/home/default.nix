{ lib, config, pkgs, inputs, ... }:

with inputs;

{
  imports = [ self.homeModules.shell ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (unison.override { enableX11 = false; })
    unison-fsmonitor
  ];

  programs.neovim = {
    extraLuaConfig =
      lib.mkAfter (builtins.readFile ../../../home/profiles/develop/nvim.lua);
    extraPackages = with pkgs; [
      gopls
      nodePackages.typescript-language-server
      terraform-ls
      texlab
      yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars))
      copilot-vim
      vim-go
    ];
  };

  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";
    font.size = 10;
    settings = {
      shell = "${pkgs.bashInteractive}/bin/bash -l";
      shell_integration = "enabled";
      enable_audio_bell = false;
      background_opacity = "0.8";
      dynamic_background_opacity = true;
    };
    extraConfig = ''
      include ${pkgs.kitty-themes}/share/kitty-themes/themes/Dracula.conf
      # disable link clicks
      mouse_map left click ungrabbed no_op
    '';
  };

  programs.mpv = let
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
    makeShader = shaders:
      lib.concatMapStringsSep ":" (s: "~~/shaders/${s}") shaders;
    makeShaderHQ = shaders:
      makeShader
      (builtins.map (builtins.replaceStrings [ "_M." "_S." ] [ "_VL." "_M." ])
        shaders);
  in {
    enable = true;
    config = {
      hwdec = "auto-safe";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      pause = true;
      osc = false;
      audio-display = false;

      osd-font = "Noto Sans";
      osd-font-size = 15;
      osd-border-size = 1;
      sub-font-size = 30;
      script-opts = "stats-font_size=4,stats-border_size=0.5";

      alang = "ja,jpn";
      slang = "enm,eng,en";

      # adapted from taiyi profile
      profile = "gpu-hq";
      vo = "gpu";
      gpu-api = "opengl";

      deband = false;
      deband-iterations = 4;
      deband-threshold = 48;
      deband-range = 24;
      deband-grain = 16;

      scale = "ewa_lanczos";
      cscale = "ewa_lanczos";
      scale-blur = 0.981251;
      cscale-blur = 0.981251;
    };
    bindings = {
      WHEEL_UP = "ignore";
      WHEEL_DOWN = "ignore";
      WHEEL_LEFT = "ignore";
      WHEEL_RIGHT = "ignore";

      "D" = "cycle deband";
      "CTRL+0" = ''
        no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';

      "CTRL+1" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_A
        }"; show-text "Anime4K: Mode A"'';
      "CTRL+2" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_B
        }"; show-text "Anime4K: Mode B"'';
      "CTRL+3" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_C
        }"; show-text "Anime4K: Mode C"'';
      "CTRL+4" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_AA
        }"; show-text "Anime4K: Mode AA"'';
      "CTRL+5" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_BB
        }"; show-text "Anime4K: Mode BB"'';
      "CTRL+6" = ''
        no-osd change-list glsl-shaders set "${
          makeShader a4k_CA
        }"; show-text "Anime4K: Mode CA"'';
    };
  };

  xdg.configFile."mpv/shaders".source = pkgs.fetchzip {
    name = "Anime4K";
    url =
      "https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip";
    hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
    stripRoot = false;
  };

  programs.gpg.enable = true;

  programs.git.extraConfig = {
    gpg.format = "ssh";
    gpg.ssh.defaultKeyCommand = "ssh-add -L";
    commit.gpgSign = true;
    tag.gpgSign = true;
  };
  home.file."${config.home.homeDirectory}/.gnupg/sshcontrol".text = ''
    829BDD7C73F5DD4FB17025FF171EF408E7866ECD
  '';
  home.file."${config.home.homeDirectory}/.gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
}
