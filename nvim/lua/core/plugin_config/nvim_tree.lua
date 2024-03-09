-- https://github.com/nvim-tree/nvim-tree.lua
-- https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvimtree/

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  auto_close = true,
  view = {
    side = "right",
  }
})

-- Keymaps
vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>')

-- Old netrw keymaps
vim.keymap.set('n', '<leader>x', ':NvimTreeFocus<CR>')
vim.keymap.set('n', '<leader>vx', ':NvimTreeFocus<CR>')


-- :NvimTreeToggle Open or close the tree. Takes an optional path argument.
-- :NvimTreeFocus Open the tree if it is closed, and then focus on the tree.
-- :NvimTreeFindFile Move the cursor in the tree for the current buffer, opening folders if needed.
-- :NvimTreeCollapse Collapses the nvim-tree recursively.


