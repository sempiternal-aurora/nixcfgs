{
  lib,
  config,
  pkgs,
  ...
}:
{

  options = {
  };

  config = {
    services.caddy = {
      enable = true;
      group = "www-data";
      virtualHosts =
        let
          caddyConfig = url: {
            extraConfig = ''
              root * /var/www/${url}/public_html
              file_server
              php_fastcgi unix/${config.services.phpfpm.pools.holonet.socket}
            '';
          };
        in
        lib.attrsets.genAttrs [
          "holonet.myria.dev"
          "holonet.auroracod.ing"
        ] caddyConfig;
    };

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      initialDatabases = [
        {
          name = "holonet";
          schema = ./holonet.sql;
        }
      ];
      ensureDatabases = [
        "holonet"
      ];
      ensureUsers = [
        {
          name = "php";
          ensurePermissions = {
            "holonet.*" = "INSERT, SELECT, UPDATE";
          };
        }
      ];
    };

    systemd.services.petro_bot = {
      description = "petro_bot";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        exec ${pkgs.petro_bot}/bin/petro_bot --token $TOKEN --database $STATE_DIRECTORY/test-db.db3
      '';

      serviceConfig = {
        Restart = "on-failure";

        User = "petro-bot";
        Group = "petro-bot";

        StateDirectory = "petro-bot";
        StateDirectoryMode = "0700";
      };

      environment = import (
        pkgs.requireFile {
          name = "petro-bot-env.nix";
          hashMode = "flat";
          hash = "sha256-/Ryz849ykpH7oegJ2hsU2LqW20wu37HUEoDN1H6IsiY=";
          message = ''
            Add the file to the store:
            $ nix store add --mode flat petro-bot-env.nix
            Get the hash:
            $ nix hash file --type sha256 petro-bot-env.nix
          '';
          meta.license = lib.licenses.free;
        }
      );
    };

    environment.systemPackages = [
      pkgs.petro_bot
    ];

    services.phpfpm = {
      phpOptions = ''
        display_errors = off;
      '';
      pools.holonet = {
        user = "php";
        group = "www-data";
        phpPackage = pkgs.php;
        settings = {
          "listen.owner" = "php";
          "listen.group" = "www-data";
          "pm" = "dynamic";
          "pm.max_children" = 10;
          "pm.start_servers" = 3;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
          "pm.max_requests" = 500;
        };
      };
    };

    users = {
      groups = {
        "petro-bot" = { };
        "www-data" = { };
      };

      users = {
        php = {
          isSystemUser = true;
          createHome = false;
          group = "www-data";
        };
        "petro-bot" = {
          isSystemUser = true;
          group = "petro-bot";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
