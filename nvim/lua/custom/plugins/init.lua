-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

return {
  { -- LazyGit
    'kdheepak/lazygit.nvim',
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
    config = function()
      vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } -- customize lazygit popup window border characters
      vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
      vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

      vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
      vim.g.lazygit_config_file_path = '' -- custom config file path
      -- OR
      vim.g.lazygit_config_file_path = {} -- table of custom config file paths
    end,
  },
  { -- copilot
    'github/copilot.vim'
  },
  { -- git fugitive
    'tpope/vim-fugitive'
  },
  { -- vim surround
    'tpope/vim-surround'
  },
  {
    'stevearc/conform.nvim',
    config = function()
      local slow_format_filetypes = { 'javascript', 'typescript', 'typescriptreact', 'vue' }
      local no_fallback_filetypes = { 'vue' }
      require('conform').setup({
        formatters_by_ft = {
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          vue = { { "prettierd", "prettier" } },
        },
        format_on_save = function(bufnr)
          if slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
          end
          local function on_format(err)
            if err and err:match("timeout$") then
              slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
          end

          return { timeout_ms = 200, lsp_fallback = not no_fallback_filetypes[vim.bo[bufnr].filetype] }, on_format
        end,

        format_after_save = function(bufnr)
          if not slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
          end

          return { lsp_fallback = not no_fallback_filetypes[vim.bo[bufnr].filetype] }
        end,
      })
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup({
        filters = {
          git_ignored = false
        },
        view = {
          side = "right",
        }
      })

      vim.keymap.set('n', '<leader>tt', '<cmd>NvimTreeToggle<CR>')
      vim.keymap.set('n', '<leader>tf', '<cmd>NvimTreeFindFile<CR>')
      vim.keymap.set('n', '<leader>tc', '<cmd>NvimTreeCollapse<CR>')
    end
  }
}
