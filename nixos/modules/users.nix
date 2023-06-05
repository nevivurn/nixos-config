# generic user-related settings
{ config, ... }:

{
  users.mutableUsers = false;

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;

  security.polkit.enable = true;

  environment.sessionVariables.TZ = config.time.timeZone;
}
