{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mine.linux-builder;
in
{
  options.mine.linux-builder = {
    enable = lib.mkEnableOption "enable linux-builder";
    memorySize = lib.mkOption {
      default = 32;
      description = "size in GB of the memory allocated to the machine";
      type = lib.types.int;
    };
    diskSize = lib.mkOption {
      default = 128;
      description = "size in GB of the disk space allocated to the machine";
      type = lib.types.int;
    };
    cores = lib.mkOption {
      default = 8;
      description = "number of cores to give to the machine";
      type = lib.types.int;
    };
    maxJobs = lib.mkOption {
      default = 4;
      description = "number of concurrent nix builds to do at once";
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    nix.linux-builder = {
      enable = true;
      package = pkgs.darwin.linux-builder-vz;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      ephemeral = true;
      inherit (cfg) maxJobs;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
        "uid-range"
      ];
      config = {
        nix.settings = {
          build-dir = "/nix/.rw-store/build";
          # needed for nixos tests with containers
          system-features = [
            "uid-range"
          ];
          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
          ];
          auto-allocate-uids = true;
          use-cgroups = true;
        };

        systemd.tmpfiles.settings."10-nix-build-dir"."/nix/.rw-store/build".d = {
          user = "root";
          group = "root";
          mode = "0755";
        };

        virtualisation = {
          darwin-builder = {
            diskSize = cfg.diskSize * 1024;
            memorySize = cfg.memorySize * 1024;
          };
          inherit (cfg) cores;
          vz.nestedVirtualization = true;
        };
      };
    };
  };
}
