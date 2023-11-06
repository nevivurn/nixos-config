{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation (finalAttrs: {
  pname = "firefox";
  version = "119.0";

  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${finalAttrs.version}/mac/en-US/Firefox%20${finalAttrs.version}.dmg";
    hash = "sha256-nqhi9iP7P/vcavXLqzSqelev8MexN4nMygPOtzzK4uk=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv firefox.app $out/Applications
    runHook postInstall
  '';

  meta.platforms = lib.platforms.darwin;
})
