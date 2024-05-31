# subset of settings of self.homeModules.shell
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    pv
    tree
    psmisc

    unixtools.xxd

    curl
    wget
    (p7zip.override { enableUnfree = true; })

    ethtool
    iw
    ldns
    mtr
    openssl
    tcpdump

    python3

    lm_sensors

    xterm # for "resize"
  ];

  home.shellAliases = {
    ls = "ls --color=tty";
    ll = "ls -l";
    la = "ls -A";
    l = "ls -alh";
    grep = "grep --color=tty";
  };

  programs.home-manager.enable = true;

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = "true";
        insert_final_newline = "true";
      };
      "*.nix" = {
        indent_style = "space";
        indent_size = 2;
      };
    };
  };

  programs.neovim = {
    enable = true;
    extraLuaConfig = builtins.readFile ./nvim.lua;
    extraPackages = with pkgs; [
      nixd
      nixfmt-rfc-style
    ];
    plugins = with pkgs.vimPlugins; [
      dracula-vim

      (nvim-treesitter.withPlugins (p: with p; [ nix ]))
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-nvim-lsp
    ];

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
  };
  programs.bash.enable = true;
  programs.tmux.enable = true;

  programs.dircolors.enable = true;
  programs.starship.enable = true;

  programs.jq.enable = true;
  programs.less.enable = true;
  programs.lesspipe.enable = true;
  programs.man.enable = true;

  programs.git = {
    enable = true;
    aliases = {
      graph = "log --graph --all --oneline";
    };
    extraConfig = {
      init.defaultBranch = "master";
      core.pager = "less -+X";
      core.quotePath = false;
    };
    ignores = [
      ".direnv"
      ".envrc"
    ];
    userName = "Yongun Seong";
    userEmail = "nevivurn@nevi.dev";
  };

  programs.ssh.enable = true;
}
