local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false,
  })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
  }
})

-- Keybindings
vim.keymap.set('n', '<leader>ca', ':CodeActionMenu<CR>')
vim.keymap.set('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>')

lsp_zero.setup()
