{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with inputs;

{
  imports = [ home-manager.darwinModules.home-manager ];

  system.stateVersion = 4;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    sharedModules = [ { home.stateVersion = "24.05"; } ];
  };

  nixpkgs.overlays = [
    self.overlays.default
    (final: prev: {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs) system config;
        overlays = [ self.overlays.default ];
      };
    })
  ];

  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
      "p7zip"
    ]
  );
  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager.users.nevivurn = import ./home;

  programs.zsh.enable = true;
  programs.bash.enable = true;

  services.nix-daemon.enable = true;

  users.users.nevivurn = {
    home = "/Users/nevivurn";
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILA46OFhojJ+Bcbv5qJ3KZQhLtYKb/54V6Dk4KAUmt20 nevivurn@dziban"
    ];
  };
  environment = {
    shells = [ pkgs.bashInteractive ];
    variables.SHELL = "/run/current-system/sw/bin/bash";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  networking = {
    hostName = "dziban";
    computerName = config.networking.hostName;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # MITM certificate from funi
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBozCCAUqgAwIBAgIRAPgffsUgkjfBw87oxCN5ABAwCgYIKoZIzj0EAwIwMDEu
      MCwGA1UEAxMlQ2FkZHkgTG9jYWwgQXV0aG9yaXR5IC0gMjAyNCBFQ0MgUm9vdDAe
      Fw0yNDAyMTUxNDA4MTRaFw0zMzEyMjQxNDA4MTRaMDAxLjAsBgNVBAMTJUNhZGR5
      IExvY2FsIEF1dGhvcml0eSAtIDIwMjQgRUNDIFJvb3QwWTATBgcqhkjOPQIBBggq
      hkjOPQMBBwNCAAQzRa2NrgDWiCE859U5J77GgxUk7AGstEUFkZPZI+IEJe02XYXY
      JnG0kj+5jxfru7lXfdRJx20MoV67aFB4bhoBo0UwQzAOBgNVHQ8BAf8EBAMCAQYw
      EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUl4Vzyq6XcXRByzt9nEipj184
      Wh8wCgYIKoZIzj0EAwIDRwAwRAIgOgEX/Nv0cLgZmzlE4M+ouMjXU1UoHbfbKVAT
      zXq44OICIEtjU3OE5abWAJRkfrkQzee6KoImzqlSAlZ2wHnLU+qb
      -----END CERTIFICATE-----
    ''
  ];
}
