{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [ inputs.self.homeModules.develop ];

  home.packages = [ pkgs.weechat ];

  home.persistence."/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/weechat"
      ".local/share/weechat"
    ];
  };
}
