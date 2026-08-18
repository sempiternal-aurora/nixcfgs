{
  lib,
  config,
  pkgs,
  inputs,
  vars,
  ...
}:
let
  cfg = config.admin-user;
in
{
  options = {
    admin-user.enable = lib.mkEnableOption "enable user module";
    admin-user.userName = lib.mkOption {
      default = "adminuser";
      description = "priviledged user's name";
    };
    admin-user.sshKeys = lib.mkOption {
      description = "your users ssh key";
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
    admin-user.homeManager = lib.mkOption {
      description = "primary user's name";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      home = "/Users/${cfg.userName}";
      description = "admin user";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs vars;
      };
      backupFileExtension = "hm-bak";
      users.${cfg.userName} = cfg.homeManager;
    };

    programs.zsh.enable = true;
  };
}
