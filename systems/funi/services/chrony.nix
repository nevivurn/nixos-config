{
  networking.timeServers = [ "time.cloudflare.com" ];
  services.chrony = {
    enable = true;
    enableNTS = true;
    extraConfig = ''
      allow 192.168.2.0/24
      allow fdbc:ba6a:38de::1/64
      allow 10.42.42.0/24
      allow fdbc:ba6a:38de:1::1/64
    '';
  };
}
