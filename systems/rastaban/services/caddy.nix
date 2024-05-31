{ lib, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withModules {
      plugins = [ { name = "github.com/mholt/caddy-l4"; } ];
      vendorHash = "sha256-MLLM9gtQ80EYQLXbNGpbhK1MfNZPV3edoaVopvqLx3Q=";
    };
    settings = {
      apps.layer4.servers = {
        http = {
          listen = [ ":80" ];
          routes = [
            {
              match = [ { http = [ ]; } ];
              handle = [
                {
                  handler = "proxy";
                  upstreams = [ { dial = [ "{l4.http.host}:80" ]; } ];
                }
              ];
            }
          ];
        };
        https = {
          listen = [ ":443" ];
          routes = [
            {
              match = [ { tls = { }; } ];
              handle = [
                {
                  handler = "proxy";
                  upstreams = [ { dial = [ "{l4.tls.server_name}:443" ]; } ];
                }
              ];
            }
          ];
        };
      };
    };
  };
  networking.firewall.interfaces."wg-proxy".allowedTCPPorts = [
    80
    443
  ];
}
