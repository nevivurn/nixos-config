{ pkgs, ... }:

{
  # unison-fsmonitor for mac
  unison-fsmonitor = pkgs.callPackage ./unison-fsmonitor {
    inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices;
  };
}
