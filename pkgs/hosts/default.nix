{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.15";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-jhdip3auFYnkXxcndsQnNCzn1cbRZfWSOYVlVOcdgOU=";
  };

  patches = [ ./remove-invalid.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 hosts $out/hosts
    runHook postInstall
  '';
}
