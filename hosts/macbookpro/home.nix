{
  lib,
  userName ? "user",
  inputs,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    ../../modules/home-manager
    inputs.nix-doom-emacs.homeModule
    inputs.nix-index-database.homeModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userName;
  home.homeDirectory = if isDarwin then "/Users/${userName}" else "/home/${userName}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  mine = {
    terminal = {
      newsboat = true;
      spotify-player = true;
      weechat = true;
      trash = true;
      mercurial = true;
      zip = true;
      zsh = isDarwin;
      fish = isLinux;
      zoxide = true;
      btop = true;
      comma = true;
      hyfetch = true;
      eza = true;
      lf = false;
      yazi = true;
      starship = true;
      yt-dlp = true;
    };
    direnv.enable = true;
    sway = {
      enable = isLinux;
      idle = true;
      powercheck = true;
      fx = true;
      terminal = lib.mkIf isLinux (lib.getExe pkgs.ghostty);
    };
    zoom.enable = false;
    teams.enable = isLinux;
    _1password = {
      enable = true;
      kwallet.enable = isLinux;
    };
    nvim = {
      enable = true;
      default = true;
      latex = isLinux;
      xdg-mime = isLinux;
    };
    isabelle = {
      enable = isLinux;
      enableNeovimIntegration = true;
    };
    jetbrains = {
      enable = true;
      intellij = true;
    };
    discord.enable = isDarwin;
    calibre.enable = isLinux;
    digital.enable = isLinux;
    firefox.enable = true;
  };

  # Packages I'm maintaining to keep an eye out for breaks
  home.packages = [
    pkgs.vampire
  ];

  programs.ghostty = lib.mkIf isLinux {
    package = null;
    systemd.enable = false;
  };

  # Allow unfree licences for some packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "1password"
      "1password-gui"
      "idea"
      "idea-ultimate"
      "mathematica"
      "zoom"
    ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/aurora/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  xdg.configFile."gdb/gdbinit" = {
    enable = true;
    text = ''
      set auto-load safe-path ~
    '';
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
