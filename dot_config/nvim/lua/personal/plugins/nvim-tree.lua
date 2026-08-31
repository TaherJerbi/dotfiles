-- Disable netrw, as recommended by nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add { 'https://github.com/nvim-tree/nvim-tree.lua' }

require('nvim-tree').setup {
  view = { side = 'right' },
}

vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file [E]xplorer' })
vim.keymap.set('n', '<leader>E', '<cmd>NvimTreeFindFile<cr>', { desc = 'Focus current file in [E]xplorer' })
