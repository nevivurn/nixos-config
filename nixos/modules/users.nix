# generic user-related settings
{
  users.mutableUsers = false;

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;

  security.polkit.enable = true;
}
