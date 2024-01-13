{ config, pkgs, inputs, ... }:

with inputs;

{
  imports = [
    home-manager.darwinModules.home-manager
  ];

  system.stateVersion = 4;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [{
      home.stateVersion = "23.11";
    }];
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

  nixpkgs.config.allowUnfree = true;
  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  # let nix-shell and flake commands follow system inputs
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;

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

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };

  networking = {
    hostName = "dziban";
    computerName = config.networking.hostName;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
