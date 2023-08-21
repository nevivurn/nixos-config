{
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

      disassoc_low_ack=1
      uapsd_advertisement_enabled=1

      auth_algs=1
      wpa=2
      wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
      wpa_pairwise=CCMP
      rsn_pairwise=CCMP
      wpa_passphrase=temporary password testing
      rsn_preauth=1
      sae_require_mfp=1
      sae_pwe=2

      ap_isolate=1

      ieee80211w=2
      beacon_prot=1
      ocv=1
      okc=1
      wpa_disable_eapol_key_retries=1
      wpa_deny_ptk0_rekey=1
    '';
  };
}
