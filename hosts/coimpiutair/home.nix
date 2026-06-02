{
  lib,
  userName ? "user",
  inputs,
  pkgs,
  ...
}:
let
  auroraPkgs = import inputs.aurora-nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ../../modules/home-manager
    # inputs.chaotic-nyx.homeManagerModules.default
    inputs.nix-doom-emacs.homeModule
    inputs.nix-index-database.homeModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userName;
  home.homeDirectory = "/home/${userName}";

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
      zsh = true;
      fish = true;
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
      enable = true;
      idle = true;
      powercheck = true;
      fx = true;
    };
    zoom.enable = true;
    teams.enable = true;
    _1password = {
      enable = true;
      kwallet.enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };
    nvim = {
      enable = true;
      default = true;
      latex = true;
      xdg-mime = true;
    };
    emacs.enable = true;
    isabelle = {
      enable = true;
      enableNeovimIntegration = true;
    };
    jetbrains = {
      enable = true;
      intellij = true;
    };
    discord.enable = true;
    calibre.enable = true;
    digital.enable = true;
    mathematica.enable = true;
    firefox.enable = true;
  };

  # Packages I'm maintaining to keep an eye out for breaks
  home.packages = [
    pkgs.vampire
    pkgs.stm32cubemx
    auroraPkgs.stm32cubeide
  ];

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
      "Wolfram_14.3.0_LIN_Bndl.sh"
      "zoom"
      "stm32cubeide"
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
      dates = "sunday";
      options = "--delete-older-than 10d";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
