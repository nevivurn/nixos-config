pkgs:

let
  inherit (pkgs) callPackage;
in

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = callPackage ./passmenu { };

  # ssh-keygen wrapper for for gpg-agent
  ssh-keygen-gpg-wrapper = callPackage ./ssh-keygen-gpg-wrapper { };
}
