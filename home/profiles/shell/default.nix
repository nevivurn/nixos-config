{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    pv
    tree

    unixtools.xxd

    curl
    wget

    (p7zip.override { enableUnfree = true; })
    unzip

    ldns
    mtr
    openssl
    tcpdump

    python3

    binutils
    gnumake

  ] ++ lib.optionals pkgs.hostPlatform.isLinux [
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
          incremental_selection = { enable = true },
        }
      EOF

      " quickfix shortcuts
      nnoremap <leader>o :copen<CR>
      nnoremap <leader>q :cclose<CR>
      map <C-n> :cnext<CR>
      map <C-p> :cprev<CR>

      " make by default
      nnoremap <leader>b :make<CR>
      set autowrite

      " unmap K
      map <S-k> <Nop>

      lua << EOF
        local on_attach = function(client, bufnr)
          local bufopts = { noremap=true, silent=true, buffer=bufnr }

          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
              buffer = bufnr,
              callback = function() vim.lsp.buf.format() end,
            })
          end
        end

        require'lspconfig'.nil_ls.setup {
          on_attach = on_attach,
          settings = {
            ['nil'] = {
              formatting = { command = { 'nixpkgs-fmt' } }
            },
          },
        }
      EOF

      lua << EOF
        local cmp = require'cmp'
        cmp.setup {
          snippet = {
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
          }),
        }

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
      EOF
    '';
    extraPackages = with pkgs; [
      nil
      nixpkgs-fmt
    ];
    plugins = with pkgs.vimPlugins; [
      dracula-vim

      (nvim-treesitter.withPlugins (p: with p; [ nix ]))
      pkgs.pkgsUnstable.vimPlugins.nvim-lspconfig

      nvim-cmp
      cmp-nvim-lsp

      vim-vsnip
      cmp-vsnip
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

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "athebyne-boot.nevi.network".user = "root";

      "cse.snu.ac.kr".user = "bacchus";
      "*.snucse.org".user = "bacchus";
      "sherry.snucse.org" = lib.hm.dag.entryBefore [ "*.snucse.org" ]
        { user = "sherry"; };
      "martini.snucse.org" = lib.hm.dag.entryBefore [ "*.snucse.org" ]
        { user = "yseong"; };

      "datium.github.com" = {
        hostname = "github.com";
        identityFile = "/home/nevivurn/code/datium/id_ed25519_datium";
        identitiesOnly = true;
      };

      # for cfds class
      "cfds.snu.ac.kr" = {
        hostname = "147.47.200.192";
        user = "shpc051";
        proxyJump = "martini.snucse.org";
      };
    };
  };
}
