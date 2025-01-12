{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    package = pkgs.pkgsUnstable.caddy.withPlugins {
      plugins = [ "github.com/mholt/caddy-l4@v0.0.0-20241111225910-3c6cc2c0ee08" ];
      hash = "sha256-DtoBrMfMb4vMQywQFL8tJhRJyW8Ky/xl2PohZv5qz0c=";
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
