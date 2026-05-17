{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.mine.firefox;
  name = config.home.username;
in
{
  imports = [
    inputs.textfox.homeManagerModules.default
  ];

  options = {
    mine.firefox.enable = lib.mkEnableOption "enable firefox module";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles."${name}" = {
        inherit name;
        id = 0;
      };
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableProfileImport = true;
        DisplayBookmarksToolbar = "never";
        RequestedLocales = "en-GB,en-US";
        SearchEngines.Default = "DuckDuckGo";

        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # BPC
          "magnolia@12.34" = {
            install_url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi";
            installation_mode = "force_installed";
          };
          # Tridactyl:
          "tridactyl.vim@cmcaine.co.uk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
            installation_mode = "force_installed";
          };
          # 1Password:
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # uwuify-doer
          "haii@willowyx.dev" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/uwuify-doer/latest.xpi";
            installation_mode = "force_installed";
          };
          # AO3 Enhancements
          "ao3-enhancements@jsmnbom" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ao3-enhancements/latest.xpi";
            installation_mode = "force_installed";
          };
          # DuckDuckGo Privacy Essentials
          "jid1-ZAdIEUB7XOzOJw@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
            installation_mode = "force_installed";
          };
          # Return youtube dislikes
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
            installation_mode = "force_installed";
          };
          "{2766e9f7-7bf2-4c72-81b9-d119eb54c753}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/remove-youtube-shorts/latest.xpi";
            installation_mode = "force_installed";
          };
          "{c84d89d9-a826-4015-957b-affebd9eb603}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/mal-sync/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    textfox = {
      enable = true;
      profiles = [ name ];
      config = {
        font = {
          family = "\"Hasklug Nerd Font Mono\", monospace";
          size = "16px";
        };
        tabs.horizontal.enable = true;
        displayNavButtons = true;
        # displayUrlbarIcons = true;
      };
    };
  };
}
