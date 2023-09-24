{ config, pkgs, inputs, ... }:

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
    firefox
  ];

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
    plugins = with pkgs.vimPlugins ;[
      nvim-treesitter.withAllGrammars
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
