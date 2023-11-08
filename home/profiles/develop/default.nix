{ config, pkgs, ... }:

{
  imports = [ ../shell ];

  home.packages = with pkgs; [
    awscli2
    docker-compose
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]))
    (kubectlWithPlugins.override { plugins = [ kubelogin-oidc ]; })
    terraform

    restic
    (unison.override { enableX11 = false; })
  ];
  home.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR:-/run/user/\${UID}}/podman/podman.sock";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.whitelist.prefix = [ "/persist/home/nevivurn/code/nevi" ];
  };

  programs.neovim = {
    extraConfig = ''
      " go settings
      function! s:build_go_files()
        let l:file = expand('%')
        if l:file =~# '^\f\+_test\.go$'
          call go#test#Test(0, 1)
        elseif l:file =~# '^\f\+\.go$'
          call go#cmd#Build(0)
        endif
      endfunction

      " go keybinds
      autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
      autocmd FileType go nmap <leader>t <Plug>(go-test)
      autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)
      autocmd FileType go nmap <leader>a <Plug>(go-alternate-edit)
      let g:go_list_type = "quickfix"

      lua << EOF
        local treesitter_parser_config = require "nvim-treesitter.parsers".get_parser_configs()
        treesitter_parser_config.templ = {
          install_info = {
            url = "https://github.com/vrischmann/tree-sitter-templ.git",
            files = {"src/parser.c", "src/scanner.c"},
            branch = "master",
          },
        }
        vim.treesitter.language.register('templ', 'templ')
      EOF

      lua << EOF
        -- TODO unduplicate this part?
        local on_attach = function(client, bufnr)
          local bufopts = { noremap=true, silent=true, buffer=bufnr }

          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
              buffer = bufnr,
              callback = function() vim.lsp.buf.format() end,
            })
          end
        end

        require'lspconfig'.terraformls.setup { on_attach = on_attach }
        require'lspconfig'.templ.setup { on_attach = on_attach }
        require'lspconfig'.texlab.setup { on_attach = on_attach }
        require'lspconfig'.tsserver.setup { on_attach = on_attach }
        require'lspconfig'.yamlls.setup {
          on_attach = on_attach,
          settings = {
            yaml = { keyOrdering = false }
          },
        }
      EOF
    '';
    extraPackages = with pkgs; [
      nodePackages.typescript-language-server
      terraform-ls
      texlab
      yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      tree-sitter-templ
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
        (pkgs.tree-sitter.buildGrammar {
          language = "templ";
          inherit (tree-sitter-templ) version src;
          meta = { }; # errors if null
        })
      ]))
      vim-go
    ];
  };

  programs.password-store = {
    enable = true;
    package =
      let
        pass = pkgs.pass.override {
          inherit pass;
          dmenuSupport = false;
          waylandSupport = true;
        };
      in
      pass.withExtensions (ext: with ext; [ pass-otp ]);
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
    sshKeys = [
      "9478FDDFE4E99B8BD79B4A0390432CE2B7E9F0B6"
      "9AF5A517D9F1E5A7A0BE52B910C0773991A8AF6D"
    ];
  };

  programs.git.extraConfig = {
    gpg.format = "ssh";
    gpg.ssh.defaultKeyCommand = "ssh-add -L";
    commit.gpgSign = true;
    tag.gpgSign = true;
  };

  home.file.".config/containers/storage.conf".text = ''
    [storage]
    driver = "overlay"

    [storage.options.overlay]
    mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
  '';

  home.file.".terraformrc".text = ''
    plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
  '';

  home.persistence."/persist/cache${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".cache"
      ".terraform.d"
      ".unison"
    ];
  };
  home.persistence."/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".aws"
      ".config/gcloud"
      ".kube"
      ".ssh"
      { directory = "code"; method = "symlink"; }
    ];
  };
}
