# generic user-related settings
{ config, ... }:

{
  users.mutableUsers = false;

  users.users.nevivurn.openssh.authorizedKeys.keys = [
    ''cert-authority,principals="nevivurn" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQ5bSq67p6GC5oE8+jglOw17CV/vtBQH/SyxoACxgti nevivurn@signer''
  ];

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;

  security.polkit.enable = true;

  environment.sessionVariables.TZ = config.time.timeZone;
}
