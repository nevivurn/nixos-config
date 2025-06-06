{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/mholt/caddy-l4@v0.0.0-20250428144642-57989befb7e6" ];
      hash = "sha256-UNOvokDRmir2RcXdsSwUxHLEKD8PA6aYEngjUPImsTo=";
    };
    settings = {
      apps.layer4.servers = {
        http = {
          listen = [ "10.42.43.3:80" ];
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
          listen = [ "10.42.43.3:443" ];
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
