{ lib, ... }:

{
  systemd.network = {
    netdevs = {
      "30-wg-home" = {
        netdevConfig = {
          Name = "wg-home";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/persist/secrets/wg-home-priv";
          ListenPort = 6666;
        };
        wireguardPeers = builtins.map (x: { wireguardPeerConfig = x; }) [
          {
            # tianyi
            AllowedIPs = [ "10.42.42.2/32" "fd5e:77c8:d76e:1::2/128" ];
            PublicKey = "JR9Zu+6QO8yBBE9WwbwEcdo6JVZ1pHsjb3P+mQIy3mY=";
            PresharedKeyFile = "/persist/secrets/wg-home-tianyi-psk";
          }
          {
            # fafnir
            AllowedIPs = [ "10.42.42.3/32" "fd5e:77c8:d76e:1::3/128" ];
            PublicKey = "W2634QLtmqji5pZzlDh5Z02KegcCf3uleQqbtctOsTk=";
            PresharedKeyFile = "/persist/secrets/wg-home-fafnir-psk";
          }
          {
            # altais
            AllowedIPs = [ "10.42.42.6/32" "fd5e:77c8:d76e:1::6/128" ];
            PublicKey = "F+Gz+s93TCYuFMYawdLF56gsjL6JNqOR7PglXbTZJgs=";
            PresharedKeyFile = "/persist/secrets/wg-home-altais-psk";
          }
        ];
      };
    };

    networks = {
      "30-wg-home" = {
        matchConfig.Name = "wg-home";
        networkConfig.Address = [ "10.42.42.1/24" "fd5e:77c8:d76e:1::1/64" ];
      };
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "virbr0";
    internalInterfaces = [ "wg-home" ];
  };

  networking.firewall.allowedUDPPorts = [ 6666 ];
}
