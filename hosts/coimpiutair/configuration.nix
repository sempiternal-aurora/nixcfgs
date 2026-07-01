# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
args@{
  inputs,
  lib,
  pkgs,
  vars,
  config,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    # You will need to generate a hardware configuration with hardware by running
    # > sudo nixos-generate-config
    # and copying the result from /etc/nixos
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs = {
    overlays = [
      inputs.nix-cachyos-kernel.overlays.default
    ];

    # Allow unfree licences for some packages
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "1password-gui"
        "1password-cli"
        "1password"
        "idea"
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
        "zoom"
        "nordvpn"
        "stm32cubeide"
        "stm32cubemx"
      ];
  };

  # Use the latest linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages =
    let
      mkCachyKernel = inputs.nix-cachyos-kernel.mkCachyKernel {
        inherit pkgs;
        buildLinux = pkgs.buildLinux;
      };
      version = pkgs.cachyosKernels.linux-cachyos-rc.version;
      src = pkgs.cachyosKernels.linux-cachyos-rc.src.src;
      kernel =
        (mkCachyKernel {
          pname = "linux-cachyos-latest-lto-zen4";
          inherit version src;
          configVariant = "linux-cachyos";
          processorOpt = "zen4";
          lto = "full";
        }).overrideAttrs
          {
            env.NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING = true;
          };
      helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
    in
    helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);

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

  admin-user = {
    enable = true;
    userName = vars.adminUser;
    homeManager = import ./home.nix (args // { userName = vars.adminUser; });
  };

  local-user = {
    enable = true;
    userName = vars.localUser;
    homeManager = import ./home.nix (args // { userName = vars.localUser; });
  };

  networking.hostName = "coimpiutair"; # Define your hostname.

  hardware.framework = {
    enableKmod = true;
    laptop13.audioEnhancement.enable = true;
  };

  # nordvpn config
  # chaotic.nordvpn.enable = true;
  # users.users."${vars.adminUser}".extraGroups = [ "nordvpn" ];
  # users.users."${vars.localUser}".extraGroups = [ "nordvpn" ];
  # networking.firewall = {
  #   # checkReversePath = false;
  #   allowedUDPPorts = [ 1194 ];
  #   allowedTCPPorts = [ 443 ];
  # };

  mine = {
    keyboard = {
      enable = true;
      caps2esc = true;
    };
    media = {
      enable = true;
      qbittorrent = false;
    };
    greetd = {
      enable = false;
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd \"systemd-cat --identifier=sway sway\"";
    };
    ly.enable = true;
    sway.enable = true;
    audio.enable = true;
    steam.enable = true;
    lutris.enable = true;
    itch.enable = true;
    prism.enable = true;
    networking = {
      enable = true;
      tailscale.enable = true;
      globalprotect.enable = true;
      bluetooth.enable = true;
    };
    printing.enable = true;
    brillo.enable = true;
    udisks2.enable = true;
    usbhotspot.enable = true;
    yazi.enable = true;
    uutils.enable = false;
    docs.enable = true;
    podman.enable = true;
    udev = {
      openocd = true;
      vivado = true;
      stm32 = true;
    };
  };

  # 1Password __MUST__ be installed as root
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      vars.adminUser
      vars.localUser
    ];
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  zramSwap = {
    enable = true;
    priority = 2;
  };
  swapDevices = [
    # {
    #   device = "/var/lib/swapfile";
    #   size = 16 * 1024;
    #   priority = 1;
    # }
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "sunday";
      options = "--delete-older-than 10d";
    };
    settings = {
      auto-optimise-store = true;
      sandbox = true;
      trusted-users = [
        "root"
        vars.adminUser
        vars.localUser
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
