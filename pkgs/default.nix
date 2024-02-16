pkgs:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };

  # kubectl with plugins
  kubectlWithPlugins = pkgs.callPackage ./kubectl-with-plugins { };

  # orpheusbetter
  orpheusbetter = pkgs.callPackage ./orpheusbetter { };
}
