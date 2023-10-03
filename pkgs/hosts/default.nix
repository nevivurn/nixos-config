{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.14.11";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-MXr9PXYdHD8aXdmNjqJ+IVmRsiJWXtKdb640ESEm4Qw=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
}
