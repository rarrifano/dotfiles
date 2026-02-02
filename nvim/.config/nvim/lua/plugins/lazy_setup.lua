-- Plugin specifications for lazy.nvim
-- Each plugin is in its own file under lua/plugins/
return {
    require('plugins.colorscheme'),
    require('plugins.telescope'),
    require('plugins.treesitter'),
    require('plugins.lsp'),
    require('plugins.copilot'),
    require('plugins.cmp'),
    require('plugins.snippets'),
    require('plugins.conform'),
    require('plugins.git'),
    require('plugins.oil'),
    require('plugins.autopairs'),
    require('plugins.avante'),
}
