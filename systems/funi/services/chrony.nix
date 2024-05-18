{ lib, config, ... }:

let cfg = config.services.chrony;
in {
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [ ];
    extraConfig = ''
      allow 192.168.2.0/24
      allow fdbc:ba6a:38de::1/64
      allow 10.42.42.0/24
      allow fdbc:ba6a:38de:1::1/64
    '' +
      # use "pool" directive instead
      lib.concatMapStringsSep "\n" (pool: "${pool} ${cfg.serverOption}") [
        "pool time.cloudflare.com nts"
        "pool nts.netnod.se nts"
        "server paris.time.system76.com nts"
        "pool kr.pool.ntp.org noselect"
      ];
  };
}
