final: prev: {
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [ ./gnucash/krw-no-fraction.patch ];
  });

  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = final.callPackage ./passmenu { };

  hosts = final.fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = "3.13.13";
    hash = "sha256-wKVdNG3Uj1CdP35GDmRi7mIAGRJCWDzgwxC5Vd77XrA=";
  };
}
