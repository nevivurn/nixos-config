{ lib, config, pkgs, ... }:

{
  imports = [ ../shell ];

  home.packages = with pkgs; [
    awscli2
    docker-compose
    google-cloud-sdk
    kubectl
    terraform

    restic
  ];
  home.sessionVariables = {
    DOCKER_HOST = "\${XDG_RUNTIME_DIR:-/run/user/\${UID}}/podman/podman.sock";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.whitelist.prefix = [ "${config.home.homeDirectory}/code/nevi" ];
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
    sshKeys = [ "9478FDDFE4E99B8BD79B4A0390432CE2B7E9F0B6" ];
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*.snucse.org" = { user = "bacchus"; };
      "cse.snu.ac.kr" = { user = "bacchus"; };
      "sherry.snucse.org" = lib.hm.dag.entryBefore [ "*.snucse.org" ]
        { user = "sherry"; };
      "martini.snucse.org" = lib.hm.dag.entryBefore [ "*.snucse.org" ]
        { user = "yseong"; };
    };
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

  home.persistence."/persist/cache/home/nevivurn" = {
    allowOther = true;
    directories = [
      ".terraform.d"
    ];
  };
  home.persistence."/persist/home/nevivurn" = {
    allowOther = true;
    directories = [
      ".aws"
      ".gnupg"
      ".local/share/password-store"
      ".ssh"
      "code"
    ];
  };
}
