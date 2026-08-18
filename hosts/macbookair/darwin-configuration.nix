args@{
  inputs,
  lib,
  vars,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.default
    ../../modules/nix-darwin
  ];

  # Necessary for using flakes on this system.
  nix = {
    settings = {
      trusted-users = [
        "root"
        vars.adminUser
      ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  mine = {
    keyboard = {
      enable = true;
      caps2esc = true;
    };
    firefox.enable = true;
    yazi.enable = true;
    discord.enable = true;
    element.enable = true;
    _1password.enable = true;
    zoom.enable = true;
    ghostty.enable = true;
  };

  admin-user = {
    enable = true;
    userName = vars.adminUser;
    homeManager = import ./home.nix (args // { userName = vars.adminUser; });
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "1password-gui"
      "discord"
      "zoom"
    ];
}
