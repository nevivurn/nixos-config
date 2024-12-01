{ lib, ... }:

# general nix config
{
  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
      "p7zip"
    ]
  );

  nix.channel.enable = false;

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
