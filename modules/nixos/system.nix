{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  options = {
    mine.usbhotspot.enable = lib.mkEnableOption "apple usb mobile hotspot support";
    mine.udisks2.enable = lib.mkEnableOption "permission to other than root mount";
    mine.brillo.enable = lib.mkEnableOption "brightness cli controls";
    mine.yazi.enable = lib.mkEnableOption "rust terminal file manager";
    mine.uutils.enable = lib.mkEnableOption "uutils coreutils rust replacement";
  };
  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.tmp.cleanOnBoot = true;

    # Set your time zone.
    time.timeZone = "Australia/Canberra";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_AU.UTF-8";

    services.usbmuxd.enable = config.mine.usbhotspot.enable;
    services.udisks2.enable = config.mine.udisks2.enable;

    security.polkit.enable = true;
    security.pam.services.swaylock = { };

    hardware.brillo.enable = config.mine.brillo.enable;

    programs.dconf.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment = {
      pathsToLink = [ "/share/zsh" ];
      systemPackages = [
        pkgs.neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        pkgs.wget
        pkgs.git
        pkgs.tmux
        pkgs.sl
      ]
      ++ lib.lists.optional config.mine.yazi.enable pkgs.yazi
      ++ lib.lists.optionals config.mine.usbhotspot.enable [
        pkgs.libimobiledevice
        pkgs.usb-modeswitch
      ]
      ++ lib.lists.optional config.mine.uutils.enable (lib.hiPrio pkgs.uutils-coreutils-noprefix);
    };

    # environment.etc = {
    #   "1password/custom_allowed_browsers" = {
    #     text = ''
    #       zen-bin
    #       zen
    #     '';
    #     mode = "0755";
    #   };
    # };

    environment.enableAllTerminfo = true;

    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };
  };
}
