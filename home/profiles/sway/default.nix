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
    noto-fonts-color-emoji

    (passmenu.override { pass = config.programs.password-store.package; })
    sway-contrib.grimshot
    wl-clipboard
    xdg-utils

    ffmpeg
    imv
    mediainfo
    yt-dlp

    gnucash
    liquidctl
    moonlight-qt
    pavucontrol
    thunderbird
    virt-manager

    discord
    webcord # for screen sharing, for now
    element-desktop-wayland
    pkgsUnstable.protonmail-bridge
    pkgsUnstable.slack
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
    settings = {
      shell_integration = "enabled";
      enable_audio_bell = false;
      background_opacity = "0.8";
      dynamic_background_opacity = true;
    };
    extraConfig = ''
      include ${pkgs.kitty-themes}/share/kitty-themes/themes/Dracula.conf
      # disable link clicks
      mouse_map left click ungrabbed no_op
    '';
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
    systemd.enable = true;
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
          "${mod}+Shift+o" = "exec loginctl lock-session";

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
        settings.memory_used_method = "memavailable";
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
      # leave enough space for per-machine modules
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
  };
  xdg.configFile."wofi/style.css".source =
    let
      dracula = pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "wofi";
        rev = "9180ba3ddda7d339293e8a1bf6a67b5ce37fdd6e";
        hash = "sha256-qC1IvVJv1AmnGKm+bXadSgbc6MnrTzyUxGH2ogBOHQA=";
      };
    in
    "${dracula}/style.css";

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
      hwdec = "auto-safe";
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

  services.swayidle = {
    enable = true;
    events =
      let swaylock = config.programs.swaylock.package; in
      [
        { command = "${swaylock}/bin/swaylock -f"; event = "lock"; }
        { command = "${swaylock}/bin/swaylock -f"; event = "before-sleep"; }
      ];
  };
  programs.swaylock = {
    enable = true;
    settings = {
      image = "~/pics/bg";
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
      ".cache/mozilla"
      ".cache/thunderbird"
      ".config/Element"
      ".config/Slack"
      ".config/WebCord"
      ".config/discord"
      ".local/state/wireplumber"
    ];
  };
}
