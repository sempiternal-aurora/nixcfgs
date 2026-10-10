{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.mine.mail;
in
{
  options = {
    mine.mail.enable = lib.mkEnableOption "Enable mail sync with isync";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.isync
      pkgs.mutt
    ];

    systemd.user = {
      timers.mbsync = {
        Unit = {
          Description = "Sync mail every 5 minutes";
        };

        Timer = {
          OnBootSec = "1min";
          OnUnitActiveSec = "5min";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      services.mbsync = {
        Unit = {
          Description = "Sync mail with mbsync";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.isync} -a";
        };
      };
    };

    xdg.configFile = {
      "mutt/muttrc" = {
        enable = true;
        text = ''
          # ============================================
          # ~/.config/mutt/muttrc - Global Configuration
          # ============================================

          # Basic Settings
          set editor = "vim"             # Editor for drafting emails
          set mail_check = 60            # Check for new mail every 60 seconds
          set timeout = 15               # Timeout for internal loops
          set sort = threads             # Sort emails by conversation threads
          set sort_aux = reverse-date-received
          set mbox_type = Maildir

          # Pager & Composing (Essential for LKML/Kernel Dev)
          set text_flowed = no           # Do not auto-wrap lines (corrupts patches)
          unset markers                  # Don't show '+' for wrapped lines
          set autoedit = yes             # Start editing right away
          set edit_headers = yes         # Let you modify headers (To, Cc, Subject) in Vim

          # Local Mail Directory Caching
          set header_cache = ~/.cache/mutt/headers
          set message_cachedir = ~/.cache/mutt/bodies

          # Shortcuts to Switch Accounts (Press F2 for Gmail, F3 for Outlook)
          folder-hook ~/Mail/Gmail/* 'source ~/.config/mutt/gmail.muttrc'
          folder-hook ~/Mail/Outlook/* 'source ~/.config/mutt/outlook.muttrc'
          macro index <F2> '<change-folder>~/Mail/Gmail/INBOX<enter>' "Switch to Gmail"
          macro index <F3> '<change-folder>~/Mail/Outlook/INBOX<enter>' "Switch to Outlook"

          # Automatically load Gmail by default on startup
          source ~/.config/mutt/gmail.muttrc

          # Fix the keybindings
          bind pager j next-line
          bind pager k previous-line
          bind pager <up> previous-line
          bind pager <down> next-line
        '';
      };
      "mutt/gmail.muttrc" = {
        enable = true;
        text = ''
          # ==========================================
          # Gmail Account Configuration
          # ==========================================
          set smtp_url = "smtps://myrialsarvay@smtp.gmail.com"
          set smtp_pass = `gpg --quiet --for-your-eyes-only --no-tty --decrypt ~/.config/mutt/gmail-pass.gpg`

          set from = "myrialsarvay@gmail.com"
          set realname = "Myria Sarvay"
          set use_from = yes

          # IMAP Folders
          set folder = "~/Mail/Gmail"
          set spoolfile = "+INBOX"
          set postponed = "+[Gmail]/Drafts"
          set record = "+[Gmail]/Sent Mail"
          set trash = "+[Gmail]/Bin"
        '';
      };
      "isyncrc" = {
        enable = true;
        text = ''
          IMAPAccount gmail
          # Address to connect to
          Host imap.gmail.com
          User myrialsarvay@gmail.com
          PassCmd "gpg --quiet --for-your-eyes-only --no-tty --decrypt ~/.config/mutt/gmail-pass.gpg"
          TLSType IMAPS
          CertificateFile /etc/ssl/certs/ca-certificates.crt

          IMAPStore gmail-remote
          Account gmail

          MaildirStore gmail-local
          SubFolders Verbatim
          Path ~/Mail/Gmail/
          Inbox ~/Mail/Gmail/INBOX

          Channel gmail
          Far :gmail-remote:
          Near :gmail-local:
          Patterns * !"mailing lists" ![Gmail]* "[Gmail]/Sent Mail" "[Gmail]/Bin" "[Gmail]/Drafts"
          Create Both
          Expunge Both
          SyncState *
        '';
      };
    };
  };
}
