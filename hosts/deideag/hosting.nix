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
      virtualHosts = {
        # Holonet archives
        "holonet.myria.dev" = {
          extraConfig = ''
            root * /var/www/holonet.myria.dev/public_html
            file_server
            php_fastcgi unix/${config.services.phpfpm.pools.holonet.socket}
          '';
        };
        "holonet.auroracod.ing" = {
          extraConfig = ''
            root * /var/www/holonet.auroracod.ing/public_html
            file_server
            php_fastcgi unix/${config.services.phpfpm.pools.holonet.socket}
          '';
        };

        "irc.myria.dev" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:7797
          '';
        };
      };
    };

    services.soju = {
      enable = true;
      hostName = "irc.myria.dev";
      tlsCertificate = "/var/lib/soju/fullchain.pem";
      tlsCertificateKey = "/var/lib/soju/privkey.pem";
      acceptProxyIP = [ "localhost" ];
      listen = [
        "irc://localhost:6667"
        "ircs://0.0.0.0:6697"
        "http://localhost:7797"
      ];
      extraConfig = ''
        file-upload fs ./uploads
      '';
    };

    # Copy certs into the soju directory
    systemd.timers.soju-certs = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "soju-certs.service";
      };
    };

    systemd.services.soju-certs = {
      path = [ pkgs.coreutils ];
      script = ''
        mkdir -p /var/lib/soju/
        cp /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/irc.myria.dev/irc.myria.dev.{crt,key} /var/lib/soju/
        rm -f /var/lib/soju/{fullchain,privkey}.pem
        mv /var/lib/soju/irc.myria.dev.crt /var/lib/soju/fullchain.pem
        mv /var/lib/soju/irc.myria.dev.key /var/lib/soju/privkey.pem
        chmod 644 /var/lib/soju/{fullchain,privkey}.pem
        chown nobody:nogroup /var/lib/soju/{fullchain,privkey}.pem
      '';
      serviceConfig = {
        Type = "oneshot";
      };
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
      6697
    ];
  };
}
