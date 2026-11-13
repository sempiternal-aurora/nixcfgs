{
  lib,
  config,
  pkgs,
  inputs,
  vars,
  ...
}:
let
  cfg = config.mine.asahi;
in
{
  options = {
    mine.asahi.enable = lib.mkEnableOption "enable asahi linux configuration";
    mine.asahi.kpep.enable = lib.mkEnableOption "Install kpep files extracted from macOS";
    mine.asahi.touchBar.enable = lib.mkEnableOption "Runs tinydfr to allow the touchbar to be used as a special keyboard";
  };
  config = lib.mkIf cfg.enable {
    # Use the systemd-boot EFI boot loader.
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = false;
      };
      kernelPackages = lib.mkForce (pkgs.linux-asahi);
    };

    hardware.asahi = {
      enable = true;
      avd = {
        enable = true;
        vaapi-support = true;
        codecs = [ "all" ];
      };
      setupAsahiSound = true;
      extractPeripheralFirmware = true;
      peripheralFirmwareDirectory = null;
    };

    hardware.apple.touchBar = lib.mkIf cfg.touchBar.enable {
      enable = true;
      settings = {
        MediaLayerDefault = true;
        ShowButtonOutlines = false;
        EnablePixelShift = true;
      };
    };

    systemd.tmpfiles.settings."10-kpep" =
      let
        kpep = pkgs.requireFile {
          name = "macOS_27";
          hashMode = "recursive";
          hash = "sha256-FGpoozZto+9fdRcwnOImV9qKK1JsoYfj9BbBUM45qZo=";
          message = ''
            Add the file to the store:
            $ nix store add /path/to/macOS_27/kpep/folder
            Get the hash:
            $ nix store hash path --algo sha256 /path/to/macOS_27/kpep/folder
          '';
        };
      in
      lib.mkIf cfg.kpep.enable {
        "/usr/share/kpep".L.argument = "${kpep}";
      };
  };
}
