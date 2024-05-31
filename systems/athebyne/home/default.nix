{
  inputs,
  config,
  pkgs,
  ...
}:

with inputs;

{
  imports = [ self.homeModules.develop ];

  home.packages = with pkgs; [ weechat ];

  home.persistence."/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/weechat"
      ".local/share/weechat"
    ];
  };
}
