# subset of settings of self.homeModules.shell
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    tree
    psmisc

    unixtools.xxd

    curl
    wget

    ethtool
    iw
    ldns
    mtr
    openssl
    tcpdump

    lm_sensors
  ];

  home.shellAliases = {
    ls = "ls --color=tty";
    ll = "ls -l";
    la = "ls -A";
    l = "ls -alh";
    grep = "grep --color=tty";
  };

  programs.home-manager.enable = true;

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = "true";
        insert_final_newline = "true";
      };
      "*.nix" = {
        indent_style = "space";
        indent_size = 2;
      };
    };
  };

  programs.bash.enable = true;
  #programs.bash.enableVteIntegration = true;
  programs.tmux.enable = true;

  programs.dircolors.enable = true;
  programs.starship.enable = true;

  programs.jq.enable = true;
  programs.less.enable = true;
  programs.lesspipe.enable = true;
  programs.man.enable = true;
}
