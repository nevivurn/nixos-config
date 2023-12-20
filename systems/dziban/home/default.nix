{ lib, config, pkgs, inputs, ... }:

with inputs;

{
  imports = [
    self.homeModules.shell
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (unison.override { enableX11 = false; })
    unison-fsmonitor
  ];

  programs.neovim = {
    extraLuaConfig = lib.mkAfter (builtins.readFile ../../../home/profiles/develop/nvim.lua);
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
    '';
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      pause = true;
      osc = false;
      audio-display = false;

      osd-font = "Noto Sans";
      osd-font-size = 20;
      osd-border-size = 1;

      alang = "ja,jpn";
      slang = "enm,eng,en";
    };
    bindings = {
      WHEEL_UP = "ignore";
      WHEEL_DOWN = "ignore";
      WHEEL_LEFT = "ignore";
      WHEEL_RIGHT = "ignore";
    };
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
