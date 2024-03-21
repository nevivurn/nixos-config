# upstream to nixpkgs if it works well
{ lib, fetchFromGitHub, stdenv, rustPlatform, CoreServices }:

rustPlatform.buildRustPackage rec {
  pname = "unison-fsmonitor";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "autozimu";
    repo = "unison-fsmonitor";
    rev = "v${version}";
    hash = "sha256-JA0WcHHDNuQOal/Zy3yDb+O3acZN3rVX1hh0rOtRR+8=";
  };
  cargoSha256 = "sha256-aqAa0F1NSJI1nckTjG5C7VLxaLjJgD+9yK/IpclSMqs=";

  buildInputs = lib.optionals stdenv.isDarwin [ CoreServices ];

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
