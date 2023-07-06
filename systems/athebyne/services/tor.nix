{
  services.tor = {
    enable = true;
    enableGeoIP = false;
    relay.onionServices."illegal-services" = {
      map = [{
        port = 80;
        target = {
          addr = "127.0.0.1";
          port = 8888;
        };
      }];
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tor" ];
  };
}
