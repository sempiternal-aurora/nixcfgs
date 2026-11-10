{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mine.nvim;
in
{
  options = {
    mine.nvim.enable = lib.mkEnableOption "enable neovim";
    mine.nvim.default = lib.mkEnableOption "set nvim as the default editor";
    mine.nvim.latex = lib.mkEnableOption "add inbuilt latex lsp support";
    mine.nvim.xdg-mime = lib.mkEnableOption "add xdg-mime neovim config";
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = cfg.xdg-mime;
      defaultApplications = {
        "application/json" = [ "nvim.desktop" ];
        "text/*" = [ "nvim.desktop" ];
      };
    };

    nixpkgs.overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          ansi-nvim = final.vimUtils.buildVimPlugin {
            name = "ansi.nvim";
            src = final.fetchFromGitHub {
              owner = "0xferrous";
              repo = "ansi.nvim";
              rev = "195b64c3da1c22c2e95648dcbdc6ed075d507064";
              hash = "sha256-GrU7Q6ZTzSWnZaNoU+yh2BDYweY6RQx6p+RNNvGx8nY=";
            };
          };
        };
      })
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = cfg.default;

      withRuby = false;
      withPython3 = false;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages =
        with pkgs;
        [
          ripgrep
          fd

          # nix config
          nil
          nixfmt

          # lua config
          lua-language-server
          stylua
        ]
        ++ lib.lists.optionals cfg.latex [
          # latex config
          texliveFull
          tex-fmt
          texlab
          ltex-ls-plus
        ];

      plugins = with pkgs.vimPlugins; [
        # colorscheme
        {
          plugin = dracula-nvim;
          type = "lua";
          config = ''
            require("dracula").setup { colors = { comment = "#B2A4D4" } }
            vim.cmd("colorscheme dracula")
          '';
        }
        # status line
        {
          plugin = lualine-nvim;
          type = "lua";
          config = "require('lualine').setup { options = { theme = 'dracula-nvim' } }";
        }
        # git
        {
          plugin = vim-fugitive;
          type = "lua";
          config = builtins.readFile ./source/fugitive.lua;
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = "require('gitsigns').setup()";
        }
        # pretty finding tui
        {
          plugin = telescope-nvim;
          type = "lua";
          config = "require('telescope').setup {}";
        }
        # undo handling
        undotree
        # easy multi-file switching
        {
          plugin = harpoon2;
          type = "lua";
          config = builtins.readFile ./source/harpoon.lua;
        }
        # linting
        {
          plugin = nvim-lint;
          type = "lua";
          config = builtins.readFile ./source/lint.lua;
        }
        # formatting
        {
          plugin = conform-nvim;
          type = "lua";
          config = builtins.readFile ./source/conform.lua;
        }
        # completion support
        {
          plugin = nvim-cmp;
          type = "lua";
          config = builtins.readFile ./source/cmp.lua;
        }
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline

        # Snippets
        luasnip
        cmp_luasnip

        # notifications bottom left
        {
          plugin = fidget-nvim;
          type = "lua";
          config = "require('fidget').setup({})";
        }

        # cool icons
        lspkind-nvim
        nvim-web-devicons

        # comment selected lines
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
            require("Comment").setup {
              toggler = {
                line = ",cc",
                block = ",Cc",
              },
              opleader = {
                line = ",c",
                block = ",C",
              },
              mappings = {
                basic = true,
                extra = false,
              },
            }
          '';
        }
        # language support
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./source/lsp.lua;
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = builtins.readFile ./source/treesitter.lua;
        }
        haskell-tools-nvim
        {
          plugin = ansi-nvim;
          type = "lua";
          config = ''
            require("ansi").setup({
              auto_enable = true,
              auto_enable_stdin = true,
              filetypes = { 'log', 'ansi', 'results' },
            })
          '';
        }
      ];

      initLua = ''

        ${builtins.readFile ./source/set.lua}
        ${builtins.readFile ./source/remap.lua}
        ${builtins.readFile ./source/langs.lua}
        local harpoon = require("harpoon")

        -- Install merlin
        vim.opt.runtimepath:append { "${pkgs.ocamlPackages.merlin}/share/merlin/vim" }

        -- Plugin keybinds
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
          local word = vim.fn.expand("<cword>")
          builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
          local word = vim.fn.expand("<cWORD>")
          builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
          builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

        vim.diagnostic.config({
          -- update_in_insert = true,
          float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        })
      '';
    };
  };
}
