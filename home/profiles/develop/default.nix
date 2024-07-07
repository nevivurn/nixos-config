{
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [ ../shell ];

  home.packages = with pkgs; [
    awscli2
    docker-compose
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    ))
    kubectl
    kubelogin-oidc
    kubernetes-helm

    restic
    (unison.override { enableX11 = false; })

    cryptsetup
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
    extraLuaConfig = lib.mkAfter (builtins.readFile ./nvim.lua);
    extraPackages = with pkgs; [
      helm-ls
      nodePackages.typescript-language-server
      pkgsUnstable.gopls
      tailwindcss-language-server
      terraform-ls
      texlab
      vscode-langservers-extracted
      yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars))
      copilot-vim
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
    pinentryPackage = pkgs.pinentry-gnome3;
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
    safe.directory = "/mnt/athebyne/share/pass";
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
      ".cache/nix"
      ".cache/nix-index"
      ".config/github-copilot"
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
      {
        directory = "code";
        method = "symlink";
      }
    ];
  };
}
