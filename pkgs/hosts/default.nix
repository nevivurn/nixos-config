{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hosts";
  version = "3.15.5";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = finalAttrs.version;
    hash = "sha256-bBQu5n/rMT8bEsBMmv3CtGUZ/ybCTuDw5E2GYZI5woU=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
})
