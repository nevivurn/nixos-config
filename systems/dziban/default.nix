{ pkgs, inputs, ... }:

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

  services.nix-daemon.enable = true;

  programs.bash.enable = true;
  programs.zsh.enable = true;
}
