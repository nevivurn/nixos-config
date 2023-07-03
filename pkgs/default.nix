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
    rev = "3.13.9";
    hash = "sha256-4CXI2vu/zBQeSzLKelaey/5WEjfroRs7LP9BvZ4CsTQ=";
  };
}
