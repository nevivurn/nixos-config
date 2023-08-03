{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.17";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-+RVOzOqw/09okCQop9l5x5dYq+UpweyvqEUo/NS/oxo=";
  };

  patches = [ ./remove-invalid.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 hosts $out/hosts
    runHook postInstall
  '';
}
