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
    pkgs.ghostty-bin
    # pkgs.element-desktop
  ];

  # Necessary for using flakes on this system.
  nix = {
    settings = {
      experimental-features = "flakes nix-command";
      trusted-users = [
        "@admin"
        "root"
        vars.adminUser
      ];
    };
    linux-builder = {
      enable = true;
      package = pkgs.darwin.linux-builder-vz;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      ephemeral = true;
      maxJobs = 4;
      config.virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
      # vz.nestedVirtualization = true;
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

  users.users."${vars.adminUser}" = {
    home = "/Users/${vars.adminUser}";
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
    users."${vars.adminUser}" = import ./home.nix (args // { userName = vars.adminUser; });
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # Prevents slow shell startup, we already compinit per-user,
  # don't need to do it at the system level too.
  programs.zsh.enableGlobalCompInit = false;
}
