-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- empty setup using defaults
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
    'OXY2DEV/markview.nvim',
    lazy = false,
    dependencies = {
      'saghen/blink.cmp',
    },
    opts = {
      preview = {
        filetypes = {
          'md',
          'markdown',
          'codecompanion',
        },
        ignore_buftypes = {},

        condition = function(buffer)
          local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt

          if bt == 'nofile' and ft == 'codecompanion' then
            return true
          elseif bt == 'nofile' then
            return false
          else
            return true
          end
        end,
      },
    },
    keys = {
      { '<leader>m', '<cmd>Markview<cr>', desc = 'Markview' },
    },
  },
  {
    'jghauser/follow-md-links.nvim',
    lazy = true,
    ft = { 'markdown', 'md' },
  },
  {
    'FabijanZulj/blame.nvim',
    lazy = true,
    keys = {
      { '<leader>gb', '<cmd>BlameToggle virtual<cr>', desc = 'Toggle Blame' },
    },
    config = function()
      require('blame').setup()
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    config = function()
      -- Configure CodeCompanion plugin with Anthropic AI models for different interaction strategies
      -- Enables AI-assisted coding with chat, inline suggestions, and command-line interactions
      -- Uses Claude 3 models (Sonnet for chat, Haiku for inline and command strategies)
      -- Provides keymaps for accepting/rejecting inline code suggestions
      -- Integrates mini_diff for displaying code changes
      require('codecompanion').setup {
        display = {
          diff = {
            provider = 'mini_diff',
          },
        },
        strategies = {
          chat = {
            adapter = {
              name = 'anthropic',
              model = 'claude-3-7-sonnet-latest',
            },
          },
          inline = {
            adapter = {
              name = 'anthropic',
              model = 'claude-3-5-haiku-latest',
            },
            keymaps = {
              accept_change = {
                modes = { n = 'ga' },
                description = 'Accept the suggested change',
              },
              reject_change = {
                modes = { n = 'gr' },
                description = 'Reject the suggested change',
              },
            },
          },
          cmd = {
            adapter = {
              name = 'anthropic',
              model = 'claude-3-5-haiku-latest',
            },
          },
        },
      }
      vim.keymap.set({ 'n', 'v' }, '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
      vim.keymap.set({ 'n', 'v' }, '<LocalLeader>a', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
      vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
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
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {}

      -- Noice keymaps with <leader>n prefix
      vim.keymap.set('n', '<leader>nd', '<cmd>Noice dismiss<cr>', { desc = 'Dismiss Noice notifications' })
      vim.keymap.set('n', '<leader>nl', '<cmd>Noice last<cr>', { desc = 'Noice Last' })
      vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<cr>', { desc = 'Noice History' })
    end,
  },
}
