pkgs:

let
  inherit (pkgs) callPackage;
in

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = callPackage ./hosts { };

  # readme generator for helm
  readme-generator-for-helm = callPackage ./readme-generator-for-helm { };

  # orpheusbetter
  orpheusbetter = callPackage ./orpheusbetter { };
}
