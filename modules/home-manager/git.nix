{ config, ... }:
{
  programs.delta.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings.init.defaultBranch = "main";
    includes = [
      {
        path = "${config.xdg.configHome}/git/gitlab.conf";
        condition = "hasconfig:remote.*.url:git@gitlab.comp.anu.edu.au:*/**";
      }
      {
        path = "${config.xdg.configHome}/git/github.conf";
        condition = "hasconfig:remote.*.url:git@github.com:*/**";
      }
      {
        path = "${config.xdg.configHome}/git/gitlab.conf";
        condition = "hasconfig:remote.*.url:https://*:*@gitlab.comp.anu.edu.au/**";
      }
      {
        path = "${config.xdg.configHome}/git/github.conf";
        condition = "gitdir:nixpkgs";
      }
    ];
  };
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  xdg.configFile = {
    "git/gitlab.conf" = {
      enable = true;
      text = ''
        [user]
            name = Myria Sarvay
            email = myria.sarvay@anu.edu.au
      '';
    };
    "git/github.conf" = {
      enable = true;
      text = ''
        [user]
            name = "sempiternal-aurora"
            email = "78790545+sempiternal-aurora@users.noreply.github.com"
      '';
    };
  };
}
