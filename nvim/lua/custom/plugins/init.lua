-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
vim.opt.conceallevel = 2
return {
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup {
        -- ...
      }

      -- github_dark, github_dark_default, github_dark_dimmed, github_dark_high_contrast,
      vim.cmd.colorscheme 'github_dark_default'
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = true,
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
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
        end,
        view = {
          width = 60,
          side = 'right',
        },
      }

      vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')
      vim.keymap.set('n', '<leader>fe', '<cmd>NvimTreeFindFile<cr>')
    end,
  },
  -- { 'github/copilot.vim' },
  {
    'windwp/nvim-ts-autotag',
    lazy = true,
    ft = { 'html', 'xml', 'jsx', 'tsx', 'vue', 'svelte', 'php', 'markdown' },
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
  {
    'echasnovski/mini.diff',
    config = function()
      local diff = require 'mini.diff'
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
  { 'numToStr/Comment.nvim' },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      {
        '<leader>nd',
        function()
          require('snacks').notifier.hide()
        end,
      },
      {
        '<leader>nh',
        function()
          require('snacks').notifier.show_history()
        end,
      },
    },
  },
}
