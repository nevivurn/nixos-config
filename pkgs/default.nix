pkgs:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };

  # kubectl with plugins
  kubectlWithPlugins = pkgs.callPackage ./kubectl-with-plugins { };

  # kavita, ref: https://github.com/NixOS/nixpkgs/pull/263649
  kavita = pkgs.callPackage ./kavita { };
} //
pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin (import ./darwin.nix pkgs)
