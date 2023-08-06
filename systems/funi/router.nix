{
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    netdevs = {
      br-lan = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
        };
      };
      he-ipv6 = {
        netdevConfig = {
          Name = "he-ipv6";
          Kind = "sit";
        };
        tunnelConfig = {
          Local = "dhcpv4";
          Remote = "74.82.46.6";
          TTL = 255;
        };
      };
    };
    networks = {
      # WAN
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          Tunnel = "he-ipv6";
        };
        dhcpV4Config = {
          UseDNS = false;
          UseNTP = false;
          UseHostname = false;
        };
        #dhcpV6Config = {
        #  UseDNS = false;
        #  UseNTP = false;
        #  UseHostname = false;
        #};
        ipv6AcceptRAConfig = {
          UseDNS = false;
        };
      };
      "15-he-ipv6" = {
        matchConfig.Name = "he-ipv6";
        networkConfig = {
          Address = "2001:470:23:5b::2/64";
          Gateway = "::";
        };
      };
      "20-lan-bridge" = {
        matchConfig.Type = "ether";
        networkConfig.Bridge = "br-lan";
        linkConfig.RequiredForOnline = false;
      };
      "30-bridge" = {
        matchConfig.Type = "bridge";
        networkConfig = {
          IPForward = "yes";
          Address = [
            "192.168.2.1/24"
            "fd07:f9bb:f9ba:1::1/64"
            "2001:470:24:5b::1/64"
          ];
          DNS = [ "127.0.0.1" "::1" ];
          DHCP = "no";
          IPv6AcceptRA = false;
        };
      };
    };
  };

  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "br-lan" ];
  };

  # NOTE: seems to have been overhauled on nixpkgs-unstable (after 23.05)
  # will require rework then.
  nixpkgs.overlays = [
    # enable OCV. Enabled after 23.05, can be removed next release
    (final: prev: {
      hostapd = prev.hostapd.overrideAttrs (prev: {
        extraConfig = prev.extraConfig + ''
          CONFIG_OCV=y
        '';
      });
    })
  ];
  services.hostapd = {
    enable = true;
    interface = "wlp4s0";
    extraConfig = ''
      interface=wlp4s0
      bridge=br-lan

      ssid=alruba2
      utf8_ssid=1

      country_code=KR
      ieee80211d=1
      ieee80211h=1
      local_pwr_constraint=3

      hw_mode=a
      channel=100

      preamble=1

      wmm_enabled=1
      ieee80211n=1
      ht_capab=[LDPC][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935][DSSS_CCK-40]

      ieee80211ac=1
      vht_capab=[MAX-MPDU-11454][RXLDPC][SHORT-GI-80][TX-STBC-2BY1][MAX-A-MPDU-LEN-EXP3][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
      vht_oper_chwidth=1
      vht_oper_centr_freq_seg0_idx=106

      auth_algs=2
      wpa=2
      wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
      wpa_pairwise=CCMP
      rsn_pairwise=CCMP
      wpa_passphrase=temporary password testing
      rsn_preauth=1

      ap_isolate=1

      ieee80211w=1
      beacon_prot=1
      ocv=1
      wpa_disable_eapol_key_retries=1
      wpa_deny_ptk0_rekey=1
    '';
  };
}
