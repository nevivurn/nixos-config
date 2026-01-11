{
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../shell ];

  home.packages = with pkgs; [
    awscli2
    docker-compose
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
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
      typescript-language-server
      pkgsUnstable.gopls
      tailwindcss-language-server
      terraform-ls
      texlab
      vscode-langservers-extracted
      yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars))
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
      pass.withExtensions (ext: [ ext.pass-otp ]);
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
    sshKeys = [
      "9478FDDFE4E99B8BD79B4A0390432CE2B7E9F0B6" # taiyi
      "2ED471433C747746BD3B710C02E9A3B5FE5122A5" # alsafi
    ];
  };

  programs.git.settings = {
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
    mount_program = "${lib.getExe pkgs.fuse-overlayfs}"
  '';

  home.persistence."/persist/cache" = {
    directories = [
      { directory = ".cache/nix"; }
      ".cache/nix-index"
      ".unison"
    ];
  };
  home.persistence."/persist" = {
    directories = [
      ".aws"
      ".config/gcloud"
      ".kube"
      ".ssh"
      { directory = "code"; }
    ];
  };
}
