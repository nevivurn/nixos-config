pkgs:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };

  # kubectl with plugins
  kubectlWithPlugins = pkgs.callPackage ./kubectl-with-plugins { };
} // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (import ./linux.nix pkgs)
  // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin (import ./darwin.nix pkgs)
