{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hosts";
  version = "3.14.106";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = finalAttrs.version;
    hash = "sha256-lvLHuWcTgGv1wAZSSmV8roKf2PEEfePoQIw8cdz2C8c=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
})
