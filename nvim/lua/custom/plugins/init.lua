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
          vim.keymap.set('n', '<leader>fe', '<cmd>NvimTreeFindFile<cr>')
        end,
        view = {
          width = 60,
          side = 'right',
        },
      }
    end,
  },
  { 'github/copilot.vim' },
  {
    'windwp/nvim-ts-autotag',
    lazy = false,
    config = function()
      require('nvim-ts-autotag').setup {
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
      }
    end,
  },
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
}
