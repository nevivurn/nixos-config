{ inputs, ... }:

# general nix config
{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    extra-experimental-features = [ "nix-command" "flakes" ];
    keep-outputs = true;
    trusted-users = [ "root" "@wheel" ];
  };

  # let nix-shell and flake commands follow system inputs
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;
}
