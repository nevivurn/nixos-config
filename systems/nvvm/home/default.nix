{ inputs, pkgs, ... }:

{
  imports = [ inputs.self.homeModules.shell ];
  home.packages = [ (pkgs.unison.override { enableX11 = false; }) ];
}
