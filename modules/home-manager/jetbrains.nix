{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mine.jetbrains;
in
{
  options = {
    mine.jetbrains.enable = lib.mkEnableOption "Whether to include jetbrains tools";
    mine.jetbrains.intellij = lib.mkEnableOption "Whether to install intellij";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.lists.optional cfg.intellij pkgs.intellij-idea;
  };
}
