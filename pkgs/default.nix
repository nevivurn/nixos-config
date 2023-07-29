{ pkgs, ... }:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };
}
