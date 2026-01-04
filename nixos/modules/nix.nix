{ lib, ... }:

# general nix config
{
  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (lib.getName pkg) [
      "7zz"
      "claude-code"
      "discord"
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
