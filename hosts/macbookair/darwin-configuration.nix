args@{
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.default
  ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.firefox
    (pkgs.isabelle.withComponents (ps: [ ps.isabelle-linter ]))
    pkgs.discord
    pkgs.zoom-us
    pkgs.element-desktop
  ];

  # Necessary for using flakes on this system.
  nix = {
    settings = {
      experimental-features = "flakes nix-command";
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

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-gui"
      "discord"
      "zoom"
    ];

  users.users.myria = {
    home = "/Users/myria";
    packages = [
      pkgs.nil
      pkgs.nixfmt

      pkgs.git

      pkgs.digital
    ];
  };

  programs._1password-gui.enable = true;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      vars = vars;
    };
    backupFileExtension = "hm-bak";
    users.myria = import ./home.nix (args // { userName = "myria"; });
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # Prevents slow shell startup, we already compinit per-user,
  # don't need to do it at the system level too.
  programs.zsh.enableGlobalCompInit = false;
}
