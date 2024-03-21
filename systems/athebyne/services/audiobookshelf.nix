{ lib, config, ... }:

let cfg = config.services.audiobookshelf;
in {
  services.audiobookshelf = { enable = true; };

  services.caddy.virtualHosts."audiobookshelf.nevi.network".extraConfig = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
      resolvers 1.1.1.1
    }

    @private remote_ip 192.168.2.0/24 fdbc:ba6a:38de::/64 10.42.42.0/24 fdbc:ba6a:38de:1::/64
    encode zstd gzip

    handle @private {
      reverse_proxy localhost:${builtins.toString cfg.port}
    }
  '';

  environment.persistence = {
    "/persist".directories = [ "/var/lib/${cfg.dataDir}" ];
  };
}
