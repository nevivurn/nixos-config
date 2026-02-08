{
  lib,
  pkgs,
  config,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      file
      moreutils
      pv
      tree

      unixtools.xxd
      yq-go

      curl
      wget
      (_7zz.override { enableUnfree = true; })

      bind.dnsutils
      mtr
      openssl
      tcpdump

      python3

      binutils
      gnumake

      man-pages
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      psmisc
      ethtool
      iw
      lm_sensors
    ];

  home.shellAliases = {
    ls = "ls --color=tty";
    ll = "ls -l";
    la = "ls -A";
    l = "ls -alh";
    grep = "grep --color=tty";
    desecret = "yq '.data | with_entries(.value |= @base64d)'";
  };

  home.sessionVariables = {
    # allow scrolling in systemd pager
    SYSTEMD_LESS = "FRSMK"; # default: FRSXMK
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
      "*.tf" = {
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
    plugins =
      with pkgs.vimPlugins;
      lib.mkMerge [
        [
          dracula-vim
          nvim-lspconfig
          nvim-cmp
          cmp-buffer
          cmp-nvim-lsp
        ]
        # hacky way to detect home/profiles/develop.nix
        # TODO: better detection?
        (lib.mkIf (!config.home.sessionVariables ? DOCKER_HOST) [
          (nvim-treesitter.withPlugins (ps: [ ps.nix ]))
        ])
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
  programs.starship.settings = {
    aws.disabled = true;
    docker_context.disabled = true;
    gcloud.disabled = true;
  };

  programs.jq.enable = true;
  programs.less.enable = true;
  programs.lesspipe.enable = true;
  programs.man.enable = true;

  programs.nix-index.enable = true;

  programs.git = {
    enable = true;
    settings = {
      alias = {
        graph = "log --graph --all --oneline";
      };
      user = {
        name = lib.mkDefault "Yongun Seong";
        email = lib.mkDefault "nevivurn@nevi.dev";
      };
      init.defaultBranch = "master";
      # allow scrolling in git pager
      core.pager = "less -+X";
      core.quotePath = false;
    };
    ignores = [
      ".direnv"
      ".envrc"
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Presumably will be deprecated / removed in the future
    matchBlocks = {
      "*".setEnv.TERM = "xterm";
    };
  };
}
