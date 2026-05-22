{
  services.prometheus = {
    exporters.node = {
      enable = true;
      openFirewall = true;
    };
    exporters.smartctl = {
      enable = true;
      openFirewall = true;
      extraFlags = [ "--smartctl.scan-device-type=by-id" ];
    };
  };
}
