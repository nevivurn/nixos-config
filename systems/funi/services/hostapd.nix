{ config, ... }:

{
  services.hostapd = {
    enable = true;

    radios.wlp4s0 = {
      countryCode = "KR";
      band = "5g";
      channel = 100;

      wifi4 = {
        enable = true;
        capabilities = [
          "LDPC"
          "HT40+"
          "HT40-"
          "SHORT-GI-20"
          "SHORT-GI-40"
          "TX-STBC"
          "RX-STBC1"
          "MAX-AMSDU-7935"
          "DSSS_CCK-40"
        ];
      };
      wifi5 = {
        enable = true;
        capabilities = [
          "MAX-MPDU-11454"
          "RXLDPC"
          "SHORT-GI-80"
          "TX-STBC-2BY1"
          "MAX-A-MPDU-LEN-EXP3"
          "RX-ANTENNA-PATTERN"
          "TX-ANTENNA-PATTERN"
        ];
        operatingChannelWidth = "80";
      };

      settings = {
        bridge = "br-lan";
        beacon_prot = true;
        ocv = true;
        okc = true;
        vht_oper_centr_freq_seg0_idx =
          config.services.hostapd.radios.wlp4s0.channel + 6;
      };

      networks = {
        wlp4s0 = {
          ssid = "alruba";
          apIsolate = true;
          authentication = {
            mode = "wpa3-sae-transition";
            wpaPasswordFile = "/secrets/wpa-passwords";
            saePasswordsFile = "/secrets/wpa-passwords";
          };
        };
      };
    };
  };
}
