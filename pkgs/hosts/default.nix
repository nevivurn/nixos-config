{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.22";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-AV1MZIlfgSStmsHL7vJ8f7pBeKs5YfSzSZiWt0uDy84=";
  };

  patches = [ ./remove-invalid.patch ];

  buildPhase = ''
    runHook preBuild
    sed -E 's/^0.0.0.0(\s)/::\1/' hosts > hosts-ipv6
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts hosts-ipv6
    runHook postInstall
  '';
}
