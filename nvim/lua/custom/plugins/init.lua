-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- empty setup using defaults
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {
        on_attach = function(bufnr)
          local api = require 'nvim-tree.api'

          -- default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')
        end,
        view = {
          side = 'right',
        },
      }
    end,
  },
}
