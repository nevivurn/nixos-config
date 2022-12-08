{ lib, config, pkgs, ... }:

{
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    file
    pv
    tree
    zbar
    killall

    unixtools.xxd

    wget
    curl

    p7zip
    unzip

    ldns
    mtr

    python3
    go
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

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
      "*.md" = {
        max_line_length = 80;
      };
    };
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set mouse=
      set relativenumber

      packadd! dracula-vim
      set termguicolors
      colorscheme dracula
      hi Normal guibg=NONE ctermbg=NONE

      lua << EOF
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
            disable = { "bash" },
          },
          indent = { enable = true },
        }
      EOF
    '';
    extraPackages = with pkgs; [ ];
    plugins = with pkgs.vimPlugins; [
      dracula-vim
      editorconfig-nvim
      nvim-treesitter.withAllGrammars
    ];

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.bash.enable = true;
  programs.bash.enableVteIntegration = true;
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
    };
    userName = "Yongun Seong";
    userEmail = "nevivurn@nevi.dev";
  };
}
