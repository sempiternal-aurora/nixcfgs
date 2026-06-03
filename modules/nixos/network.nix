{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.mine.networking;
in
{
  options.mine.networking = {
    tailscale.enable = lib.mkEnableOption "install tailscale client";
    globalprotect.enable = lib.mkEnableOption "globalprotect vpn gui";
    bluetooth.enable = lib.mkEnableOption "bluetooth support";
    enable = lib.mkEnableOption "networking";
    iwdBackend = lib.mkEnableOption "use iwd backend for network manager";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true; # Easiest to use and most distros use this by default.
        wifi.backend = if cfg.iwdBackend then "iwd" else "wpa_supplicant";
        plugins = [
          pkgs.networkmanager-openvpn
          pkgs.networkmanager-openconnect
        ];
      };

      wireless.iwd.settings = lib.mkIf cfg.iwdBackend {
        General.EnableNetworkConfiguration = true;
        Network.NameResolvingService = "resolvconf";
      };
    };

    systemd.tmpfiles.settings."10-iwd" =
      let
        ANU-Secure = pkgs.requireFile {
          name = "ANU-Secure.8021x";
          hashMode = "flat";
          hash = "sha256-EUZu8LGW4wSR6j636bFl1EumVUcyg76E0haJ22rqWPA=";
          message = ''
            Add the file to the store:
            $ nix store add --mode flat ANU-Secure.8021x
            Get the hash:
            $ nix hash file --type sha256 ANU-Secure.8021x
          '';
          meta.license = lib.licenses.free;
        };
      in
      lib.mkIf cfg.iwdBackend {
        "/var/lib/iwd/ANU-Secure.8021x".L.argument = "${ANU-Secure}";
      };

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    services.tailscale = {
      enable = cfg.tailscale.enable;
      useRoutingFeatures = "client";
    };

    # VPN Stuff
    environment.systemPackages = lib.lists.optional cfg.globalprotect.enable pkgs.gpclient;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    hardware.bluetooth.enable = cfg.bluetooth.enable;
    services.blueman = {
      enable = cfg.bluetooth.enable;
    };
  };
}
