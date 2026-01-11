{
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.self.homeModules.develop ];

  home.packages = [ pkgs.weechat ];

  home.persistence."/persist" = {
    directories = [
      ".config/weechat"
      ".local/share/weechat"
    ];
  };
}
