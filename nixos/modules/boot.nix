{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;

  # NOTE: remove if we ever bump stateVersion >= 26.11
  boot.zfs.forceImportRoot = false;

  services.fwupd.enable = true;
}
