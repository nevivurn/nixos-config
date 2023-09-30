{ inputs, pkgs, ... }:

with inputs;

{
  imports = [
    self.homeModules.sway
  ];

  # We have a real GPU
  programs.mpv.config = {
    profile = "gpu-hq";
    scale = "ewa_lanczossharp";
    cscale = "ewa_lanczossharp";
  };

  home.packages = with pkgs; [
    picocom
  ];
}
