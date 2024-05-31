{ lib, inputs, ... }:

# general nix config
{
  nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) [ "p7zip" ]);

  nix.settings = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-outputs = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
