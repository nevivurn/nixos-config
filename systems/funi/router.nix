{
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
      };
      br-lan = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "vlan";
        };
        vlanConfig.Id = 101;
      };
      br-guest = {
        netdevConfig = {
          Name = "br-guest";
          Kind = "vlan";
        };
        vlanConfig.Id = 102;
      };
    };
    networks = {
      # WAN
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          UseDNS = false;
          UseNTP = false;
          UseHostname = false;
        };
        #dhcpv6Config = {
        #  UseDNS = false;
        #  UseNTP = false;
        #  UseHostname = false;
        #};
        #ipv6AcceptRAConfig = {
        #  UseDNS = false;
        #};
      };
      "20-lan-bridge" = {
        matchConfig.Type = "ether";
        networkConfig.Bridge = "br0";
        bridgeVLANs = [{
          bridgeVLANConfig = {
            VLAN = "101-102";
            PVID = 101;
            EgressUntagged = 101;
          };
        }];
      };
      "30-bridge" = {
        matchConfig.Type = "bridge";
        networkConfig = {
          VLAN = [ "br-lan" "br-guest" ];
        };
        bridgeVLANs = [{
          bridgeVLANConfig = {
            VLAN = "101-102";
            PVID = 101;
            EgressUntagged = 101;
          };
        }];
      };
      "40-bridge-lan" = {
        matchConfig = {
          Name = "br-lan";
          Type = "vlan";
        };
        networkConfig = {
          Address = [ "192.168.1.1/24" ];
          DNS = [ "127.0.0.1" "::1" ];
          DHCP = "no";
          IPv6AcceptRA = false;
        };
      };
      "40-bridge-guest" = {
        matchConfig = {
          Name = "br-guest";
          Type = "vlan";
        };
        networkConfig = {
          Address = [ "192.168.10.1/24" ];
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
  services.hostapd = {
    enable = true;
    interface = "wlp4s0";
    extraConfig = ''
      interface=wlp4s0
      bridge=br0

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
      #ocv=1
      wpa_disable_eapol_key_retries=1
      wpa_deny_ptk0_rekey=1
    '';
  };
}
