# general nix config
{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    extra-experimental-features = [ "nix-command" "flakes" ];
    keep-outputs = true;
    trusted-users = [ "root" "@wheel" ];
  };
}
