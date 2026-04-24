-- Harpoon 2: fast file bookmarking and navigation
return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ha', function() require('harpoon'):list():add() end,                                    desc = 'Harpoon: add file' },
      { '<leader>hh', function() local h = require('harpoon') h.ui:toggle_quick_menu(h:list()) end,     desc = 'Harpoon: menu' },
      { '<leader>1',  function() require('harpoon'):list():select(1) end,                               desc = 'Harpoon: file 1' },
      { '<leader>2',  function() require('harpoon'):list():select(2) end,                               desc = 'Harpoon: file 2' },
      { '<leader>3',  function() require('harpoon'):list():select(3) end,                               desc = 'Harpoon: file 3' },
      { '<leader>4',  function() require('harpoon'):list():select(4) end,                               desc = 'Harpoon: file 4' },
      { '<leader>]',  function() require('harpoon'):list():next() end,                                  desc = 'Harpoon: next' },
      { '<leader>[',  function() require('harpoon'):list():prev() end,                                  desc = 'Harpoon: prev' },
    },
    opts = {},
  },
}
