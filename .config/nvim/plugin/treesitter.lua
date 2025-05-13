require 'nvim-treesitter.configs'.setup {
    auto_install = true,
    indent = { enable = true, disable = { "yaml" } },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
