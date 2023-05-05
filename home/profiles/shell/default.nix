{ lib, config, pkgs, ... }:

{
  imports = [ ../../modules ];

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    file
    pv
    tree
    zbar
    psmisc

    unixtools.xxd

    curl
    wget

    p7zip
    unzip

    ldns
    mtr
    openssl

    go_1_20
    openjdk17
    python3

    binutils
    gcc
    gnumake

    man-pages
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
      "*.tf" = {
        indent_style = "space";
        indent_size = 2;
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

      " go settings
      function! s:build_go_files()
        let l:file = expand('%')
        if l:file =~# '^\f\+_test\.go$'
          call go#test#Test(0, 1)
        elseif l:file =~# '^\f\+\.go$'
          call go#cmd#Build(0)
        endif
      endfunction

      autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
      autocmd FileType go nmap <leader>t <Plug>(go-test)
      autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)
      autocmd FileType go nmap <leader>a <Plug>(go-alternate-edit)
      let g:go_list_type = "quickfix"

      lua << EOF
        local on_attach = function(client, bufnr)
          local bufopts = { noremap=true, silent=true, buffer=bufnr }
          -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
              buffer = bufnr,
              callback = function() vim.lsp.buf.format() end,
            })
          end
        end

        require'lspconfig'.rnix.setup { on_attach = on_attach }
        require'lspconfig'.terraformls.setup { on_attach = on_attach }

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
      rnix-lsp
      terraform-ls
    ];
    plugins = with pkgs.vimPlugins; [
      dracula-vim

      nvim-treesitter.withAllGrammars
      nvim-lspconfig

      nvim-cmp
      cmp-nvim-lsp

      vim-vsnip
      cmp-vsnip

      vim-go

      editorconfig-nvim
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
}
