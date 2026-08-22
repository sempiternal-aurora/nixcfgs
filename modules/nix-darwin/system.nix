{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    mine._1password.enable = lib.mkEnableOption "password management app";
    mine.yazi.enable = lib.mkEnableOption "rust terminal file manager";
    mine.firefox.enable = lib.mkEnableOption "mozilla web browser";
    mine.discord.enable = lib.mkEnableOption "messaging app";
    mine.element.enable = lib.mkEnableOption "matrix messaging app";
    mine.zoom.enable = lib.mkEnableOption "online meetings app";
    mine.ghostty.enable = lib.mkEnableOption "terminal emulator";
    mine.isabelle.enable = lib.mkEnableOption "proof system";
    mine.teams.enable = lib.mkEnableOption "enable teams module";
  };
  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Set your time zone.
    time.timeZone = "Australia/Sydney";

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
      ++ lib.lists.optional config.mine.firefox.enable pkgs.firefox
      ++ lib.lists.optional config.mine.discord.enable pkgs.discord
      ++ lib.lists.optional config.mine.teams.enable pkgs.teams
      ++ lib.lists.optional config.mine.isabelle.enable (
        pkgs.isabelle.withComponents (ps: [
          ps.isabelle-linter
        ])
      )
      ++ lib.lists.optional config.mine.zoom.enable pkgs.zoom-us
      ++ lib.lists.optional config.mine.element.enable pkgs.element-desktop
      ++ lib.lists.optional config.mine.ghostty.enable pkgs.ghostty-bin
      ++ lib.lists.optional config.mine.yazi.enable pkgs.yazi;
    };

    programs._1password-gui.enable = config.mine._1password.enable;
    programs._1password.enable = config.mine._1password.enable;

    security.pam.services.sudo_local.touchIdAuth = true;

    environment = {
      enableAllTerminfo = true;
      variables = {
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
      };
    };

    # Prevents slow shell startup, we already compinit per-user,
    # don't need to do it at the system level too.
    programs.zsh.enableGlobalCompInit = false;
  };
}
