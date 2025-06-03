pkgs:

let
  inherit (pkgs) callPackage;
in

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = callPackage ./hosts { };
}
