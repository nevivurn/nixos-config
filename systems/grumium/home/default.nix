{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.self.homeModules.shell

    ../../../private/systems/grumium/home/default.nix
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (unison.override { enableX11 = false; })
    unison-fsmonitor
  ];

  programs.neovim = {
    extraLuaConfig = lib.mkAfter (builtins.readFile ../../../home/profiles/develop/nvim.lua);
    extraPackages = with pkgs; [
      helm-ls
      nodePackages.typescript-language-server
      pkgsUnstable.gopls
      terraform-ls
      vscode-langservers-extracted
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
    font.size = 11;
    settings = {
      shell = "${lib.getExe pkgs.bashInteractive} -l";
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
}
