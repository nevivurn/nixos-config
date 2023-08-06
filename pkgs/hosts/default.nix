{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.19";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-VtrnU7JLW6sri0FHgRVDUmtxwCplYN1aPmP6hgV+Hoc=";
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
