{
  lib,
  config,
  pkgs,
  ...
}:
let
  modifier = "Mod4";
  cfg = config.mine.sway;
  screenshotDir = "~/Pictures/Screenshots";
  # terminal = lib.getExe pkgs.kitty;
  menu = "${pkgs.tofi}/bin/tofi-run | xargs swaymsg exec --";
  drun = "${pkgs.tofi}/bin/tofi-drun | xargs swaymsg exec --";
  font = pkgs.nerd-fonts.hasklug;
  warnDischarge = "10";
  warnCharge = "90";
  swaylock = lib.getExe pkgs.swaylock-effects;
  pgrep = "${pkgs.procps}/bin/pgrep";
  swaymsg = "${pkgs.swayfx}/bin/swaymsg";
  playerctl = lib.getExe pkgs.playerctl;
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  firefox = lib.getExe pkgs.firefox;
  kill = "${pkgs.procps}/bin/kill";
  polkit-mate = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
  acpi = lib.getExe pkgs.acpi;
  grep = lib.getExe pkgs.gnugrep;
  wc = "${pkgs.coreutils}/bin/wc";
  sleep = "${pkgs.coreutils}/bin/sleep";
  dunstify = "${pkgs.dunst}/bin/dunstify";
  grim = lib.getExe pkgs.grim;
  swappy = lib.getExe pkgs.swappy;
  slurp = lib.getExe pkgs.slurp;
  nm-applet = lib.getExe pkgs.networkmanagerapplet;
  blueman-applet = "${pkgs.blueman}/bin/blueman-applet";
  rquickshare = lib.getExe pkgs.rquickshare;
  fish = lib.getExe pkgs.fish;
  powercheck = pkgs.writeShellScriptBin "powercheck" ''
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"

    #Set percentage at which notifications should be sent
    warn_charge=${warnCharge}
    warn_discharge=${warnDischarge}

    battery_num=$(${acpi} | ${grep} -v 'unavailable' | ${grep} -o "Battery [0-9]" | ${grep} -o "[0-9]")

    if [[ $( ${acpi} | ${grep} "Battery ''${battery_num}: Discharging" | ${wc} -l) == 1 ]]; then
      current_charge=$(${acpi} | ${grep} -o "Battery ''${battery_num}: Discharging, [0-9]*%" | ${grep} -o "[0-9]*%" | ${grep} -o "[0-9]*")
      if [[ $current_charge -le $warn_discharge ]]; then
        ${dunstify} -r 7693 -u critical "Low Battery!" "Charge is at ''${current_charge} percent!"
      fi
    #elif [[ $( acpi | grep "Battery ''${battery_num}: Charging" | wc -l) == 1 ]]; then
    #  current_charge=$(acpi | grep -o "Battery ''${battery_num}: Charging, [0-9]*%" | grep -o "[0-9]*%" | grep -o "[0-9]*")
    #  if [[ $current_charge -ge $warn_charge ]]; then
    #    dunstify -r 7693 -u critical "Stop Charging!" "Battery is at ''${current_charge} percent!"
    #  fi
    else
      ${dunstify} -C 7693
    fi
  '';
in
{
  options = {
    mine.sway = {
      enable = lib.mkEnableOption "enable sway module";
      fx = lib.mkEnableOption "Extra SwayFX config";
      idle = lib.mkEnableOption "Whether to use swayidle";
      powercheck = lib.mkEnableOption "enable low power notifications";
      wallpaper = lib.mkOption {
        default = "~/Pictures/Wallpapers/wallpaper";
        type = lib.types.str;
      };
      terminal = lib.mkOption {
        default = lib.getExe pkgs.ghostty;
        type = lib.types.str;
      };
    };
    mine.zoom.enable = lib.mkEnableOption "enable zoom module";
    mine.teams.enable = lib.mkEnableOption "enable teams module";
    mine.discord.enable = lib.mkEnableOption "enable discord module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      font
      pkgs.wl-clipboard
      pkgs.dconf
      # pkgs.discord-krisp
      pkgs.vlc
      pkgs.pwvucontrol
      pkgs.handlr-regex
      pkgs.image-roll
      pkgs.playerctl
      pkgs.rquickshare
      pkgs.viu
    ]
    ++ lib.lists.optional config.mine.discord.enable pkgs.discord
    ++ lib.lists.optional config.mine.teams.enable pkgs.teams-for-linux
    ++ lib.lists.optional config.mine.zoom.enable pkgs.zoom-us;

    services.playerctld.enable = true;

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Hasklug Nerd Font Mono" ];
    };

    xdg.mimeApps = {
      enable = true;
      associations.added = { };
      defaultApplications = {
        "image/png" = [ "image-roll.desktop" ];
        "image/jpg" = [ "image-roll.desktop" ];
        "image/jpeg" = [ "image-roll.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "video/mp4" = [ "vlc.desktop" ];
        "text/cache-manifest" = [ "nvim.desktop" ];
        "text/calendar" = [ "nvim.desktop" ];
        "text/coffeescript" = [ "nvim.desktop" ];
        "text/css" = [ "nvim.desktop" ];
        "text/csv" = [ "nvim.desktop" ];
        "text/jade" = [ "nvim.desktop" ];
        "text/jsx" = [ "nvim.desktop" ];
        "text/less" = [ "nvim.desktop" ];
        "text/markdown" = [ "nvim.desktop" ];
        "text/mathml" = [ "nvim.desktop" ];
        "text/mdx" = [ "nvim.desktop" ];
        "text/n3" = [ "nvim.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "text/prs.lines.tag" = [ "nvim.desktop" ];
        "text/richtext" = [ "nvim.desktop" ];
        "text/rtf" = [ "nvim.desktop" ];
        "text/sgml" = [ "nvim.desktop" ];
        "text/shex" = [ "nvim.desktop" ];
        "text/slim" = [ "nvim.desktop" ];
        "text/spdx" = [ "nvim.desktop" ];
        "text/stylus" = [ "nvim.desktop" ];
        "text/tab-separated-values" = [ "nvim.desktop" ];
        "text/troff" = [ "nvim.desktop" ];
        "text/turtle" = [ "nvim.desktop" ];
        "text/uri-list" = [ "nvim.desktop" ];
        "text/vcard" = [ "nvim.desktop" ];
        "text/vnd.curl" = [ "nvim.desktop" ];
        "text/vnd.curl.dcurl" = [ "nvim.desktop" ];
        "text/vnd.curl.mcurl" = [ "nvim.desktop" ];
        "text/vnd.curl.scurl" = [ "nvim.desktop" ];
        "text/vnd.dvb.subtitle" = [ "nvim.desktop" ];
        "text/vnd.familysearch.gedcom" = [ "nvim.desktop" ];
        "text/vnd.fly" = [ "nvim.desktop" ];
        "text/vnd.fmi.flexstor" = [ "nvim.desktop" ];
        "text/vnd.graphviz" = [ "nvim.desktop" ];
        "text/vnd.in3d.3dml" = [ "nvim.desktop" ];
        "text/vnd.in3d.spot" = [ "nvim.desktop" ];
        "text/vnd.sun.j2me.app-descriptor" = [ "nvim.desktop" ];
        "text/vnd.wap.wml" = [ "nvim.desktop" ];
        "text/vnd.wap.wmlscript" = [ "nvim.desktop" ];
        "text/vtt" = [ "nvim.desktop" ];
        "text/x-asm" = [ "nvim.desktop" ];
        "text/x-c" = [ "nvim.desktop" ];
        "text/x-component" = [ "nvim.desktop" ];
        "text/x-fortran" = [ "nvim.desktop" ];
        "text/x-handlebars-template" = [ "nvim.desktop" ];
        "text/x-java-source" = [ "nvim.desktop" ];
        "text/x-lua" = [ "nvim.desktop" ];
        "text/x-markdown" = [ "nvim.desktop" ];
        "text/x-nfo" = [ "nvim.desktop" ];
        "text/x-opml" = [ "nvim.desktop" ];
        "text/x-org" = [ "nvim.desktop" ];
        "text/x-pascal" = [ "nvim.desktop" ];
        "text/x-processing" = [ "nvim.desktop" ];
        "text/x-sass" = [ "nvim.desktop" ];
        "text/x-scss" = [ "nvim.desktop" ];
        "text/x-setext" = [ "nvim.desktop" ];
        "text/x-sfv" = [ "nvim.desktop" ];
        "text/x-suse-ymp" = [ "nvim.desktop" ];
        "text/x-uuencode" = [ "nvim.desktop" ];
        "text/x-vcalendar" = [ "nvim.desktop" ];
        "text/x-vcard" = [ "nvim.desktop" ];
        "text/xml" = [ "nvim.desktop" ];
        "text/yaml" = [ "nvim.desktop" ];
      };
    };

    programs.kitty = {
      enable = false;
      font = {
        name = "Hasklug Nerd Font Mono";
        size = 16;
      };
      settings = {
        disable_ligatures = "cursor";
        background_opacity = 0.9;
      };
      keybindings = {
        "kitty_mod+r" = "no-op";
      };
      shellIntegration.enableZshIntegration = true;
      themeFile = "Dracula";
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "Hasklug Nerd Font Mono";
        font-size = "16";
        theme = "dracula";
        command = "${fish} --interactive";
        maximize = true;
        background-opacity = 0.9;
      };
      themes = {
        dracula = {
          palette = [
            "0=#21222c"
            "1=#ff5555"
            "2=#50fa7b"
            "3=#f1fa8c"
            "4=#bd93f9"
            "5=#ff79c6"
            "6=#8be9fd"
            "7=#f8f8f2"
            "8=#6272a4"
            "9=#ff6e6e"
            "10=#69ff94"
            "11=#ffffa5"
            "12=#d6acff"
            "13=#ff92df"
            "14=#a4ffff"
            "15=#ffffff"
          ];
          background = "282a36";
          foreground = "f8f8f2";
          cursor-color = "f8f8f2";
          cursor-text = "282a36";
          selection-foreground = "f8f8f2";
          selection-background = "44475a";
        };
      };
    };

    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
    };

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        indicator = true;
        ring-color = "f5c2e7";
        key-hl-color = "b4b3fe";
        inside-color = "1e1e2e";
        image = cfg.wallpaper;
        effect-scale = 0.4;
        effect-vignette = "0.2:0.5";
        effect-blur = "4x2";
        datestr = "%a %e.%m.%Y";
        timestr = "%k:%M";
        indicator-radius = 100;
      };
    };

    home.pointerCursor = {
      enable = true;
      gtk = {
        size = 24;
        enable = true;
      };
      sway = {
        size = 24;
        enable = true;
      };
      x11.enable = true;
      package = pkgs.dracula-theme;
      name = "Dracula-cursors";
      size = 48;
    };

    gtk = {
      enable = true;
      font = {
        package = font;
        size = 12;
        name = "Hasklug Nerd Font Regular";
      };
      theme = {
        name = "Dracula";
        package = pkgs.dracula-theme;
      };
      iconTheme = {
        name = "Dracula";
        package = pkgs.dracula-icon-theme;
      };
      gtk4 = {
        inherit (config.gtk) theme;
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false; # Temporary build fix (see https://github.com/nix-community/home-manager/issues/5379 )
      package = null;
      config = {
        modifier = modifier;
        terminal = cfg.terminal;
        menu = menu;
        fonts = {
          names = [ "Hasklug Nerd Font Mono" ];
          size = 16.0;
        };
        gaps = {
          inner = 20;
          outer = -5;
        };
        floating = {
          border = 2;
          titlebar = false;
        };
        colors.focused = {
          border = "#A483C2";
          background = "#734F96";
          text = "#FFFFFF";
          indicator = "#E6E6FA";
          childBorder = "#734F96";
        };
        window = {
          border = 2;
          titlebar = false;
        };
        output = {
          "*".bg = "${cfg.wallpaper} fill";
          eDP-1 = {
            scale = "1";
            resolution = "2256x1504";
            position = "0,0";
          };
        };
        input."type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          scroll_factor = "1";
        };
        defaultWorkspace = "workspace number 1";
        keybindings = lib.mkOptionDefault {
          "${modifier}+Shift+d" = "exec \"${drun}\"";
          "${modifier}+Alt+f" = "exec firefox";
          "${modifier}+Alt+d" = "exec discord";
          # "${modifier}+Alt+c" = "exec code";
          "${modifier}+Alt+s" = "exec steam";
          "${modifier}+x" = "exec swaylock";
          "${modifier}+Shift+e" = "exec swaymsg exit";
          "${modifier}+Shift+b" = "exec tofi-books";
          "${modifier}+Shift+v" = "exec copyq show";
          "F11" = "fullscreen toggle";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86MonBrightnessUp" = "exec brillo -q -A 5";
          "XF86MonBrightnessDown" = "exec brillo -q -U 5";
          "${modifier}+Print" = "mode \"screenshot\"";
          "${modifier}+p" = "mode \"screenshot\"";
        };
        modes = {
          "screenshot" = {
            "1" =
              "exec '${grim} -g \"$(${slurp})\" ${screenshotDir}/ps_$(date +\"%Y%m%d%H%M%S\").png', mode \"default\"";
            "2" = "exec '${grim} ${screenshotDir}/ps_$(date +\"%Y%m%d%H%M%S\").png', mode \"default\"";
            "3" = "exec '${grim} -g \"$(${slurp})\" - | ${wl-copy}', mode \"default\"";
            "4" = "exec '${grim} - | ${wl-copy}', mode \"default\"";
            "5" = "exec '${grim} -g \"$(${slurp})\" - | ${swappy} -f -', mode \"default\"";
            Return = "mode \"default\"";
            Escape = "mode \"default\"";
            "${modifier}+Print" = "mode \"default\"";
          };
          "resize" = {
            h = "resize shrink width 10px";
            j = "resize grow height 10px";
            k = "resize shrink height 10px";
            l = "resize grow width 10px";
            Left = "resize shrink width 10px";
            Down = "resize grow height 10px";
            Up = "resize shrink height 10px";
            Right = "resize grow width 10px";
            Return = "mode \"default\"";
            Escape = "mode \"default\"";
            "${modifier}+r" = "mode \"default\"";
          };
        };
        bars = [ ];
      };
      extraConfig = lib.mkIf cfg.fx ''
        # window corner radius in px
        corner_radius 15

        # Window background blur
        blur enable
        blur_xray off
        blur_passes 2
        blur_radius 10

        shadows enable
        shadows_on_csd off
        shadow_blur_radius 20
        shadow_color #0000007F

        # inactive window fade amount. 0.0 = no dimming, 1.0 = fully dimmed
        default_dim_inactive 0.05
        dim_inactive_colors.unfocused #000000FF
        dim_inactive_colors.urgent #900000FF

        # Move minimized windows into Scratchpad (enable|disable)
        scratchpad_minimize disable
      '';
      xwayland = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      systemd.enable = true;
    };
    home.sessionVariables = {
      MOX_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland-egl";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      NIXOS_OZONE_WL = "1";
    };

    services.copyq = {
      enable = true;
      systemdTarget = "sway-session.target";
    };

    xdg.configFile."copyq/themes/dracula.ini" = {
      enable = true;
      source =
        pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "copyq";
          rev = "76ef555efc93df71e04ad7865222ff623cc582c7";
          hash = "sha256-knJxlkd0+Qbb1+JgUA2qWNpUoW3G2BVCAmjsdLBGU1k=";
        }
        + "/dracula.ini";
    };

    xdg.configFile."handlr/handlr.toml" = {
      enable = true;
      text = ''
        enable_selector = true
        selector = "tofi --prompt-text='Open With ==>'"
        term_exec_args = "-e"
        expand_wildcards = true
      '';
    };

    systemd.user = {
      timers.powercheck = lib.mkIf cfg.powercheck {
        Unit = {
          Description = "periodically run powercheck";
        };

        Timer = {
          OnCalendar = "minutely";
        };

        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };

      services = {
        powercheck = {
          Unit = {
            Description = "powercheck";
          };

          Service = {
            Type = "simple";
            ExecStart = "${powercheck}/bin/powercheck";
          };
        };

        blueman-applet = {
          Unit = {
            Description = "Blueman applet";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install = {
            WantedBy = [ "sway-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = blueman-applet;
            ExecReload = "${kill} -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            KillMode = "mixed";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        rquickshare = {
          Unit = {
            Description = "RQuickShare";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install = {
            WantedBy = [ "sway-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = rquickshare;
            ExecReload = "${kill} -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            KillMode = "mixed";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        udiskie = {
          Unit = {
            Description = "udiskie mount daemon";
            After = [ "graphical-session-pre.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install = {
            WantedBy = [ "sway-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStartPre = sleep + " 1";
            ExecStart = "${pkgs.udiskie}/bin/udiskie";
            ExecReload = "${kill} -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            KillMode = "mixed";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        network-manager-applet = {
          Unit = {
            Description = "Network Manager applet";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install = {
            WantedBy = [ "sway-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = nm-applet;
            ExecReload = "${kill} -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            KillMode = "mixed";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        polkit-mate-authentication-agent-1 = {
          Unit = {
            Description = "polkit-mate-authentication-agent-1";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = polkit-mate;
            ExecReload = "${kill} -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            KillMode = "mixed";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };

          Install = {
            WantedBy = [ "sway-session.target" ];
          };
        };
      };
    };

    services.swayidle = {
      enable = cfg.idle;
      events = {
        before-sleep = "${playerctl} pause; ${swaylock} -f";
      };
      systemdTargets = [ "sway-session.target" ];
      timeouts = [
        {
          timeout = 300;
          command = "${swaylock} -f";
        }
        {
          timeout = 900;
          command = "${swaymsg} 'output * dpms off'";
        }
        {
          timeout = 15;
          command = "if ${pgrep} -x swaylock; then ${swaymsg} 'output * dpms off'; fi";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
      ];
    };

    services.dunst = {
      enable = true;
      iconTheme = {
        package = pkgs.dracula-icon-theme;
        name = "Dracula";
      };
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          width = 600;
          height = 600;
          origin = "top-right";
          offset = "10x50";
          scale = 0;
          notification_limit = 0;
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 300;
          progress_bar_max_width = 600;
          indicate_hidden = "yes";
          transparency = 15;
          separator_height = 1;
          padding = 8;
          horizontal_padding = 10;
          text_icon_padding = 0;
          frame_width = 0;
          frame_color = "#282A36";
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "Hasklug Nerd Font Mono 20";
          line_height = 0;
          markup = "full";
          format = "%s %p\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 128;
          stick_history = "yes";
          history_length = 20;
          dmenu = "${pkgs.tofi}/bin/tofi --horizontal false --result-spacing 5 --height 500";
          browser = "${firefox} -new-tab";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 15;
          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;
          mouse_left_click = "do_action, close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_current";
        };

        urgency_low = {
          background = "#282A36";
          foreground = "#6272A4";
          timeout = 10;
        };

        urgency_normal = {
          background = "#282A36";
          foreground = "#BD93F9";
          timeout = 10;
        };

        urgency_critical = {
          background = "#FF5555";
          foreground = "#F8F8F2";
          frame_color = "#FF5555";
          timeout = 0;
        };
      };
    };

    # The package provides some icons that are good to have available.
    xdg.systemDirs.data = [ "${pkgs.networkmanagerapplet}/share" ];

    programs.tofi = {
      enable = true;
      settings = {
        font = "\"${font}/share/fonts/opentype/NerdFonts/Hasklug/HasklugNerdFont-Regular.otf\"";
        font-size = 24;
        hint-font = true;
        text-color = "#FFFFFF";
        prompt-background = "#00000000";
        prompt-background-padding = 0;
        prompt-background-corner-radius = 0;
        placeholder-color = "#FFFFFFA8";
        placeholder-background = "#00000000";
        placeholder-background-padding = 0;
        placeholder-background-corner-radius = 0;
        input-background = "#00000000";
        input-background-padding = 0;
        input-background-corner-radius = 0;
        default-result-background = "#00000000";
        default-result-background-padding = 0;
        default-result-background-corner-radius = 0;
        selection-color = "#BF94E4";
        selection-background = "#00000000";
        selection-background-padding = 0;
        selection-background-corner-radius = 0;
        selection-match-color = "#00000000";
        text-cursor-style = "bar";
        text-cursor-corner-radius = 0;
        prompt-text = "\">>= \"";
        prompt-padding = 0;
        placeholder-text = "Search";
        num-results = 0;
        result-spacing = 30;
        horizontal = true;
        min-input-width = 0;
        width = 1600;
        height = 76;
        background-color = "#1B1D1E";
        outline-width = 1;
        outline-color = "#080800";
        border-width = 4;
        border-color = "#A483C2";
        corner-radius = 15;
        padding-top = 8;
        padding-left = 8;
        padding-right = 8;
        padding-bottom = 8;
        clip-to-padding = true;
        scale = true;
        output = "\"\"";
        anchor = "center";
        exclusive-zone = -1;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        margin-bottom = 0;
        hide-cursor = true;
        text-cursor = false;
        history = true;
        matching-algorithm = "normal";
        require-match = true;
        auto-accept-single = true;
        hide-input = false;
        hidden-character = "*";
        physical-keybindings = true;
        print-index = false;
        drun-launch = false;
        late-keyboard-init = false;
        multi-instance = false;
        ascii-input = false;
      };
    };

    xdg.configFile."waybar/style.css" = {
      enable = true;
      source = ./source/style.css;
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = [ "sway-session.target" ];
      };
      settings.mainBar = {
        layer = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        position = "left";
        height = null;
        width = null;
        spacing = 0;
        margin-top = 15;
        margin-bottom = 15;
        margin-left = 15;
        margin-right = 5;
        fixed-center = false;
        ipc = true;
        bar_id = "bar-0";

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [
          "cpu#1"
          "cpu#2"
          "memory#1"
          "memory#2"
          "temperature#1"
          "temperature#2"
        ];
        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "pulseaudio#2"
          "backlight"
          "backlight#2"
          "battery"
          "battery#2"
          "tray"
          "clock"
          "clock#2"
          "sway/language"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          disable-click = false;
          all-outputs = true;
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
          };
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "󰈹";
            "3" = "󰨞";
            "4" = "󰙯";
            "5" = "󰎆";
            "6" = "󰓓";
          };
        };

        backlight = {
          interval = 2;
          #device = "amdgpu_bl0";
          format = "{icon}";
          format-icons = [ "" ];
          on-scroll-up = "brillo -q -A 5";
          on-scroll-down = "brillo -q -U 5";
          smooth-scrolling-threshold = 1;
        };

        "backlight#2" = {
          interval = 2;
          #device = "amdgpu_bl0";
          format = "{percent}%";
          on-scroll-up = "brillo -q -A 5";
          on-scroll-down = "brillo -q -U 5";
          smooth-scrolling-threshold = 1;
        };

        battery = {
          interval = 60;
          #bat = "BAT1";
          #adapter = "ACAD";
          full-at = 100;
          design-capacity = false;
          states = {
            good = 95;
            warning = 30;
            critical = 0;
          };
          format = "{icon}";
          format-charging = "󰂄";
          format-plugged = "";
          format-full = "󰁹";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format-time = "{H}h {M}min";
          tooltip = true;
        };

        "battery#2" = {
          interval = 60;
          #bat = "BAT1";
          #adapter = "ACAD";
          full-at = 100;
          design-capacity = false;
          states = {
            good = 95;
            warning = 30;
            critical = 0;
          };
          format = "{capacity}%";
          format-charging = "{capacity}%";
          format-plugged = "{capacity}%";
          format-full = "Full";
          format-alt = "{time}";
          format-time = "{H}h";
          tooltip = false;
        };

        clock = {
          interval = 60;
          tooltip-format = "<big>{:%Y}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            format = {
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          format = "{:%H}";
        };

        "clock#2" = {
          interval = 60;
          tooltip-format = "<big>{:%Y}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            format = {
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          format = "{:%M}";
        };

        "clock#3" = {
          interval = 60;
          format = "{:%p}";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        network = {
          interval = 5;
          #interface = "wlan*", // (Optional) To force the use of this interface, set it for netspeed to work
          format-wifi = "";
          format-ethernet = "󰈀";
          format-linked = "";
          format-disconnected = "󰤮";
          format-disabled = "󰲛";
          tooltip-format = "{essid} :  {bandwidthUpBits} |  {bandwidthDownBits}";
          on-click = "[[ ! `pidof nm-connection-editor` ]] && nm-connection-editor || pkill nm-connection-e";
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟";
          format-bluetooth = "";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󰂰";
            headset = "󰋎";
            phone = "";
            portable = "";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          scroll-step = 5.0;
          on-click = "amixer set Master toggle";
          on-click-right = "pavucontrol";
          smooth-scrolling-threshold = 1;
        };

        "pulseaudio#2" = {
          format = "{volume}%";
          format-muted = "Mute";
          format-bluetooth = "{volume}%";
          format-bluetooth-muted = "Mute";
          format-source = "{volume}%";
          scroll-step = 5.0;
          on-click = "amixer set Master toggle";
          on-click-right = "pavucontrol";
          smooth-scrolling-threshold = 1;
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        "sway/language" = {
          format = "{}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
          tooltip = "true";
          tooltip-format = "{long}";
        };

        "cpu#1" = {
          format = "";
        };

        "cpu#2" = {
          interval = 1;
          format = "{usage}%";
        };

        "memory#1" = {
          format = "󰉉";
        };

        "memory#2" = {
          interval = 1;
          format = "{percentage}%";
        };

        "temperature#1" = {
          format = "";
        };

        "temperature#2" = {
          interval = 1;
          format = "{temperatureC}°C";
          critical-threshold = 80;
        };
      };
    };

    services.udiskie = {
      enable = true;
      settings = {
        program_options = {
          terminal = "${cfg.terminal} -d";
        };
      };
    };
  };
}
