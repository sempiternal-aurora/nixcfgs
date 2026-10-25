local twoIndent = vim.api.nvim_create_augroup("TwoIndent", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "c", "nix" },
    group = twoIndent,
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})
