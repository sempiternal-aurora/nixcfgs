{
  lib,
  config,
  ...
}:
let
  cfg = config.mine.keyboard;
in
{
  options.mine.keyboard = {
    enable = lib.mkEnableOption "Enable Keybinding management";
    caps2esc = lib.mkEnableOption "Swap Capslock and Escape Keys";
  };

  config = lib.mkIf cfg.enable {
    system.keyboard = {
      enableKeyMapping = true;
      swapCapsLockAndEscape = cfg.caps2esc;
    };
  };
}
