final: prev:

let extras = import ./default.nix final; in

{
  inherit (extras) hosts passmenu caddyWithCloudflare;

  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [
      ./gnucash/krw-no-fraction.patch
      ./gnucash/extra-quote-sources.patch
    ];
  });
}
