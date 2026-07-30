{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.mine.isabelle;
in
{
  options = {
    mine.isabelle.enable = lib.mkEnableOption "Install Isabelle";
    mine.isabelle.enableNeovimIntegration = lib.mkEnableOption "Setup Isabelle neovim extension";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.self.outputs.overlays.default
    ];

    programs.neovim.plugins = lib.mkIf cfg.enableNeovimIntegration (
      with pkgs.vimPlugins;
      [
        {
          plugin = isabelle-lsp-nvim;
          type = "lua";
          config = ''
            require("isabelle-lsp").setup({
              isabelle_path = "${pkgs.isabelle}/bin/isabelle",
              unicode_symbols = true,
            })

            vim.lsp.enable('isabelle')
          '';
        }
        isabelle-syn-nvim
      ]
    );

    home.packages = [
      (pkgs.isabelle.withComponents (p: [
        p.isabelle-linter
        pkgs.afp
      ]))
    ];

    # home.file.".isabelle/isabelle-lsp" = {
    #   enable = cfg.enableNeovimIntegration;
    #   recursive = true;
    #   source = inputs.isabelle;
    #   onChange = "pwd > ~/pwd.txt";
    # };
  };
}
