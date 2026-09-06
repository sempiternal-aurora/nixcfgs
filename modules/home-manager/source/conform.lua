require("conform").setup({
    formatters_by_ft = {
        nix = { "nixfmt" },
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        bib = { "tex-fmt" },
        tex = { "tex-fmt" },
    },
    formatters = {
        stylua = {
            args = {
                "--search-parent-directories",
                "--indent-type",
                "Spaces",
                "--respect-ignores",
                "--stdin-filepath",
                "$FILENAME",
                "-",
            },
        },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})
