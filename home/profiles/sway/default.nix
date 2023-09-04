{ lib, config, pkgs, ... }:

let
  draculaColors = {
    bg = "#282a36";
    fg = "#f8f8f2";
    sel = "#44475a";
    com = "#6272a4";

    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
  };
in
{
  imports = [ ../develop ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    (passmenu.override { pass = config.programs.password-store.package; })
    sway-contrib.grimshot
    wl-clipboard
    xdg-utils

    ffmpeg
    imv
    mediainfo
    yt-dlp

    pkgsUnstable.gnucash
    liquidctl
    moonlight-qt
    pavucontrol
    thunderbird
    virt-manager

    discord
    webcord # for screen sharing, for now
    element-desktop
    protonmail-bridge
    slack
    weechat
  ];

  gtk.enable = true;
  gtk.theme = { package = pkgs.dracula-theme; name = "Dracula"; };
  gtk.gtk2.extraConfig = ''
    gtk-button-images = 0
    gtk-menu-images = 0
    gtk-toolbar-style = GTK_TOOLBAR_TEXT
  '';
  gtk.gtk3.extraConfig = {
    gtk-button-images = false;
    gtk-menu-images = false;
    gtk-toolbar-style = "GTK_TOOLBAR_TEXT";
  };
  home.pointerCursor = {
    package = pkgs.dracula-theme;
    name = "Dracula-cursors";
    gtk.enable = true;
    x11.enable = true;
    size = 24;
  };

  xdg.userDirs.enable = true;
  xdg.userDirs.download = "${config.home.homeDirectory}/dl";
  xdg.userDirs.pictures = "${config.home.homeDirectory}/pics";

  programs.bash.profileExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      trap -- 'systemctl --user stop graphical-session.target' EXIT
      sway
      exit
    fi
  '';

  programs.firefox.enable = true;

  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";
    font.size = 10;
    theme = "Dracula";
    settings = {
      shell_integration = "enabled";
      enable_audio_bell = false;
      background_opacity = "0.8";
      dynamic_background_opacity = true;
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-hangul
      fcitx5-mozc
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    config = {
      fonts = { names = [ "FiraCode Nerd Font" ]; size = 10.0; };

      input = {
        "type:keyboard" = { xkb_options = "korean:ralt_hangul"; };
      };
      output = {
        "*" = { bg = "~/pics/bg fill"; };
        HDMI-A-1 = { pos = "0 0"; };
        DP-3 = { pos = "1920 0"; };
      };

      focus.followMouse = false;
      workspaceAutoBackAndForth = true;
      floating.modifier = "Mod4";

      keybindings =
        let
          mod = "Mod4";
          left = "h";
          right = "l";
          up = "k";
          down = "j";

          term = "kitty";

          menu = "wofi --show run";
          passMenu = "PASSMENU_DMENU='wofi --show dmenu' PASSMENU_XDOTOOL='${pkgs.wtype}/bin/wtype -s 100 -d 20 -' passmenu";
        in
        {
          "${mod}+Return" = "exec ${term}";

          "${mod}+Space" = "focus mode_toggle";
          "${mod}+Shift+Space" = "floating toggle";

          "${mod}+a" = "focus parent";
          "${mod}+q" = "focus child";

          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "split toggle";
          "${mod}+e" = "layout toggle split";
          "${mod}+w" = "layout tabbed";

          "${mod}+Shift+q" = "kill";
          #"${mod}+Shift+o" = "exec loginctl lock-session";

          "${mod}+r" = "mode resize";
          "${mod}+Shift+e" = "mode exit";

          "${mod}+d" = "exec ${menu}";

          "${mod}+p" = "exec ${passMenu} -t";
          "${mod}+Mod1+p" = "exec ${passMenu} -c";
          "${mod}+Shift+p" = "exec ${passMenu} -o -t";
          "${mod}+Mod1+Shift+p" = "exec ${passMenu} -o -c";

          "${mod}+Prior" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
          "${mod}+Next" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
          "${mod}+Home" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ 1";
          "${mod}+End" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "Control+Space" = "exec makoctl dismiss";
          "Control+Escape" = "exec makoctl restore";
        } //
        (
          lib.foldl' (a: b: a // b) { }
            (lib.mapAttrsToList
              (dir: key: {
                "${mod}+${key}" = "focus ${dir}";
                "${mod}+Shift+${key}" = "move ${dir}";
                "${mod}+Control+${key}" = "move workspace to output ${dir}";
              })
              { inherit up down left right; })
        ) //
        (
          lib.foldl' (a: b: a // b) { }
            (map
              (num:
                let
                  ws = toString num;
                  key = if num != 10 then toString num else "0";
                in
                {
                  "${mod}+${key}" = "workspace number ${ws}";
                  "${mod}+Shift+${key}" = "move container to workspace number ${ws}; workspace number ${ws}";
                })
              (lib.range 1 10))
        );

      modes =
        let
          left = "h";
          right = "l";
          up = "k";
          down = "j";
          reset = { Return = "mode default"; Escape = "mode default"; };
        in
        {
          resize = {
            ${left} = "resize shrink width 5";
            ${right} = "resize grow width 5";
            ${up} = "resize shrink height 5";
            ${down} = "resize grow height 5";
          } // reset;
          exit = {
            e = "exit";
            "Shift+r" = "exec systemctl reboot";
            "Shift+p" = "exec systemctl poweroff";
          } // reset;
        };

      bars = [{
        statusCommand = "i3status";

        trayOutput = "none";
        extraConfig = lib.concatMapStrings
          (x: "bindsym button${toString x} nop\n")
          (lib.range 1 9);

        fonts = { names = [ "FiraCode Nerd Font" ]; size = 10.0; };

        colors = with draculaColors; {
          background = bg;
          focusedBackground = bg;

          separator = com;
          focusedSeparator = com;

          statusline = fg;
          focusedStatusline = fg;

          focusedWorkspace = { background = purple; border = purple; text = fg; };
          activeWorkspace = { background = com; border = com; text = fg; };
          inactiveWorkspace = { background = bg; border = bg; text = fg; };
          urgentWorkspace = { background = red; border = red; text = fg; };
          bindingMode = { background = red; border = red; text = fg; };
        };
      }];

      colors = with draculaColors; {
        focused = { background = purple; border = purple; childBorder = purple; indicator = pink; text = fg; };
        focusedInactive = { background = com; border = com; childBorder = com; indicator = com; text = fg; };
        unfocused = { background = bg; border = bg; childBorder = bg; indicator = bg; text = fg; };
        urgent = { background = red; border = red; childBorder = red; indicator = red; text = fg; };
      };
      floating.border = 3;
      floating.titlebar = false;
      window.border = 3;
      window.titlebar = false;
      gaps.inner = 10;
    };

    extraConfig = ''
      tiling_drag disable
    '';
  };

  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = with draculaColors; {
      color_good = green;
      color_degraded = orange;
      color_bad = red;
      markup = "pango";
    };

    modules = {
      "cpu_usage" = {
        position = 0;
        settings.format = "&#xf085; %usage";
        settings.degraded_threshold = 80;
        settings.max_threshold = 101;
        settings.separator = false;
      };
      "memory" = {
        position = 1;
        settings.format = "&#xf2db; %percentage_used";
        settings.threshold_degraded = "20%";
        settings.threshold_critical = "10%";
      };
      "disk /" = {
        position = 2;
        settings.format = "&#xf1c0; %percentage_used";
        settings.threshold_type = "percentage_avail";
        settings.low_threshold = 80;
      };
      "volume pulse" = {
        position = 3;
        settings.format = "&#xf028; %volume";
        settings.format_muted = "&#xf028; (%volume)";
        settings.device = "pulse";
      };
      "time" = {
        position = 9;
        settings.format = "%Y-%m-%d (%a) %H:%M:%S";
      };
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      insensitive = true;
      lines = 5;
      width = "15%";
    };
    # from https://github.com/dracula/wofi/blob/master/style.css
    style = ''
      window {
        margin: 0px;
        border: 1px solid #bd93f9;
        background-color: #282a36;
        font-family: 'FiraCode Nerd Font';
      }
      #input {
        margin: 5px;
        border: none;
        color: #f8f8f2;
        background-color: #44475a;
      }
      #inner-box {
        margin: 5px;
        border: none;
        background-color: #282a36;
      }
      #outer-box {
        margin: 5px;
        border: none;
        background-color: #282a36;
      }
      #scroll {
        margin: 0px;
        border: none;
      }
      #text {
        margin: 5px;
        border: none;
        color: #f8f8f2;
      }
      #entry:selected {
        background-color: #44475a;
      }
    '';
  };

  services.mako = {
    enable = true;
    layer = "overlay";
    font = "Noto Sans";
  } //
  (with draculaColors; {
    backgroundColor = bg;
    borderColor = purple;
    textColor = fg;
  });

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      pause = true;
      osc = false;
      audio-display = false;

      osd-font = "Noto Sans";
      osd-font-size = 20;
      osd-border-size = 1;

      alang = "ja,jpn";
      slang = "enm,eng,en";
    };
    bindings = {
      WHEEL_UP = "ignore";
      WHEEL_DOWN = "ignore";
      WHEEL_LEFT = "ignore";
      WHEEL_RIGHT = "ignore";
    };
  };

  services.gammastep = {
    enable = true;
    latitude = 37.56;
    longitude = 126.99;
  };

  home.persistence."/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/Moonlight Game Streaming Project"
      ".config/dconf"
      ".config/desmume"
      ".config/fcitx5"
      ".config/protonmail"
      ".config/weechat"
      ".gnupg"
      ".local/share/gnucash"
      ".local/share/password-store"
      ".local/share/protonmail"
      ".local/share/weechat"
      ".mozilla"
      ".thunderbird"
      "dl"
      "pics"
    ];
  };
  home.persistence."/persist/cache${config.home.homeDirectory}" = {
    directories = [
      ".config/Slack"
      ".config/discord"
      ".config/WebCord"
      ".config/Element"

      ".local/state/wireplumber"
    ];
  };
}
