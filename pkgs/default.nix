pkgs:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };

  # caddy with extra plugins
  caddyWithPlugins = pkgs.callPackage ./caddy-with-plugins { };

  # kubectl with plugins
  kubectlWithPlugins = pkgs.callPackage ./kubectl-with-plugins { };
} //
pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin (import ./darwin.nix pkgs)
