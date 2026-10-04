# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
args@{
  inputs,
  lib,
  pkgs,
  vars,
  modulesPath,
  ...
}:
# let
#   calamares-nixos-autostart = pkgs.makeAutostartItem {
#     name = "io.calamares.calamares";
#     package = pkgs.calamares-nixos;
#   };
# in
{
  imports = [
    ../../modules/nixos
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
    inputs.home-manager.nixosModules.default
  ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;

  isoImage.edition = "myria";

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

  admin-user = {
    enable = true;
    userName = vars.adminUser;
    homeManager = import ./home.nix (args // { userName = vars.adminUser; });
  };

  # Whitelist wheel users to do anything
  # This is useful for things like pkexec
  #
  # WARNING: this is dangerous for systems
  # outside the installation-cd and shouldn't
  # be used anywhere else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = [
    pkgs.gparted
    # # Calamares for graphical installation
    # pkgs.libsForQt5.kpmcore
    # pkgs.calamares-nixos
    # calamares-nixos-autostart
    # pkgs.calamares-nixos-extensions
    # # Get list of locales
    # pkgs.glibcLocales
  ];

  # Support choosing from any locale
  i18n.supportedLocales = [ "all" ];

  boot.plymouth.enable = true;

  # VM guest additions to improve host-guest interaction
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;
  virtualisation.hypervGuest.enable = true;
  services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
  # The VirtualBox guest additions rely on an out-of-tree kernel module
  # which lags behind kernel releases, potentially causing broken builds.
  virtualisation.virtualbox.guest.enable = false;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "nixos";
    };
    defaultSession = "sway";
  };

  mine = {
    keyboard = {
      enable = true;
      caps2esc = true;
    };

    sway.enable = true;
    audio.enable = true;
    networking = {
      enable = true;
      globalprotect.enable = false;
      bluetooth.enable = true;
    };
    brillo.enable = true;
    udisks2.enable = true;
    usbhotspot.enable = true;
    yazi.enable = true;
    docs.enable = true;
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
  #system.copySystemConfiguration = true; # Unavailable with flakes

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
