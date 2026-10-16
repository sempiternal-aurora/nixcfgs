{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.mine.sway;
  sway = if cfg.fx then pkgs.swayfx else pkgs.sway;
in
{
  options = {
    mine.sway.enable = lib.mkEnableOption "sway tiling window manager";
    mine.sway.fx = lib.mkEnableOption "Use swayfx over normal sway";
  };
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [ sway ];
      wlr.enable = true;
    };

    programs.sway = {
      enable = true;
      package = sway;
    };
  };
}
