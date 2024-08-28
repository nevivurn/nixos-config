{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  hostname = "grumium";
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

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
    inputs.self.overlays.default
    (final: prev: {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs) system config;
        overlays = [ inputs.self.overlays.default ];
      };
    })
  ];

  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
      "p7zip"
      "terraform"
    ]
  );

  # set up NIX_PATH and registry
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
  nix.registry.nixpkgs.to = {
    type = "path";
    path = inputs.nixpkgs;
  };

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
    hostName = hostname;
    computerName = config.networking.hostName;
  };
}
