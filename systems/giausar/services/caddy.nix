{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withModules {
      plugins = [
        {
          name = "github.com/mholt/caddy-l4";
          # Bump once nixpkgs' caddy advances past 2.8
          # https://github.com/mholt/caddy-l4/pull/185#issuecomment-2072916437
          version = "v0.0.0-20240604210608-ce9789f602eb";
        }
      ];
      vendorHash = "sha256-04i1EeSyqwCVbO8XlzRggOMuuFFtvmv+gyJn12Hm4A0=";
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
