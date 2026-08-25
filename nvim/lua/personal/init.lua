vim.opt.relativenumber = true
vim.o.colorcolumn = '100'

vim.filetype.add {
  extension = { gql = 'graphql' },
  pattern = { ['[Dd]ockerfile%..*'] = 'dockerfile' },
}

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })

-- Like <leader>y, but joins soft-wrapped markdown back into one line per block:
-- takes a motion in normal mode (<leader>ryip), the selection in visual mode.
vim.keymap.set('x', '<leader>ry', function() require('personal.reflow').visual() end, { desc = '[R]eflowed [Y]ank to clipboard' })
vim.keymap.set('n', '<leader>ry', function()
  vim.o.operatorfunc = "v:lua.require'personal.reflow'.operator"
  return 'g@'
end, { expr = true, desc = '[R]eflowed [Y]ank to clipboard' })

require('which-key').add { { '<leader>r', group = '[R]eflow', mode = { 'n', 'v' } } }

require 'personal.plugins.lazygit'
require 'personal.plugins.github-theme'
require 'personal.plugins.lsp'
require 'personal.plugins.formatting'
require 'personal.plugins.treesitter'
require 'personal.plugins.telescope'
require 'personal.plugins.nvim-tree'
