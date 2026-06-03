# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

args@{
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hosting.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };

  systemd.targets.multi-user.enable = true;

  users.mutableUsers = false;
  admin-user = {
    enable = true;
    userName = vars.adminUser;
    homeManager = import ./home.nix (args // { userName = vars.adminUser; });
    sshKeys = import (
      pkgs.requireFile {
        name = "nyla-ssh-keys.nix";
        hashMode = "flat";
        hash = "sha256-bvcznDkKoaOTwmk39tpex8FfKH5mxfN0ArrkzXotwXI=";
        message = ''
          Add the file to the store:
          $ nix store add --mode flat nyla-ssh-keys.nix
          Get the hash:
          $ nix hash file --type sha256 nyla-ssh-keys.nix
        '';
        meta.license = lib.licenses.free;
      }
    );
  };

  # Enable passwordless sudo.
  security.sudo.extraRules = [
    {
      users = [ vars.adminUser ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.getty.autologinUser = null;

  local-user.enable = false;

  networking.hostName = vars.configuration; # Define your hostname.

  # Allow unfree licences for some packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "1password-gui"
      "1password-cli"
      "1password"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "zoom"
    ];

  mine = {
    keyboard = {
      enable = true;
      caps2esc = true;
    };
    media.enable = false;
    networking = {
      enable = true;
      tailscale.enable = false;
    };
    printing.enable = false;
    udisks2.enable = false;
    usbhotspot.enable = false;
    yazi.enable = true;
    uutils.enable = false;
    docs.enable = false;
  };

  zramSwap = {
    enable = false;
    priority = 2;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "sunday";
      options = "--delete-older-than 10d";
    };
    settings = {
      auto-optimise-store = true;
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
