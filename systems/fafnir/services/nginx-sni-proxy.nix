{
  services.nginx = {
    enable = true;
    streamConfig = ''
      resolver 127.0.0.53;
      server {
        listen [::]:443;
        ssl_preread on;
        proxy_pass $ssl_preread_server_name:443;
      }
    '';
  };
  networking.firewall.interfaces = {
    wg51.allowedTCPPorts = [ 443 ];
    wg52.allowedTCPPorts = [ 443 ];
  };
}
