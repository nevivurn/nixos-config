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

  nixpkgs.overlays = [ self.overlays.default ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  home-manager.users.nevivurn = import ./home;

  programs.zsh.enable = true;
  programs.bash.enable = true;

  services.nix-daemon.enable = true;
  users.users.nevivurn.home = "/Users/nevivurn";
  users.users.nevivurn.shell = pkgs.bashInteractive;
  environment.loginShell = "${pkgs.bashInteractive}/bin/bash -l";

  networking = {
    hostName = "dziban";
    computerName = config.networking.hostName;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}