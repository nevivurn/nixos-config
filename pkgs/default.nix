{ pkgs, ... }:

{
  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = pkgs.callPackage ./passmenu { };

  # hosts list for malware, ads
  hosts = pkgs.callPackage ./hosts { };

  # caddy with cloudflare DNS plugin
  caddyWithCloudflare = pkgs.callPackage ./caddy-with-plugins {
    plugins = [{ name = "github.com/caddy-dns/cloudflare"; }];
    vendorHash = "sha256-/7RiceI/DY3BzFuPSRmgTk+UaXP+HB4aeM1TDor/LS8=";
  };
}
