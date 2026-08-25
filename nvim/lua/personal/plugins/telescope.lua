-- telescope.setup merges per-picker (see telescope/config.lua: set_pickers),
-- so this is safe to call again on top of the base config's setup() call.
require('telescope').setup {
  pickers = {
    find_files = { hidden = true },
  },
}

local builtin = require 'telescope.builtin'

-- Same as the base <leader><leader> buffer picker, but adds <C-x> to delete
-- the selected buffer without leaving the picker.
vim.keymap.set('n', '<leader><leader>', function()
  builtin.buffers {
    attach_mappings = function(prompt_bufnr, map)
      local action_state = require 'telescope.actions.state'
      map({ 'n', 'i' }, '<C-x>', function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        current_picker:delete_selection(function(selection)
          local ok, err = pcall(vim.api.nvim_buf_delete, selection.bufnr, { force = false })
          if not ok then vim.notify(err, vim.log.levels.WARN) end
        end)
      end)
      return true
    end,
  }
end, { desc = '[ ] Find existing buffers' })
