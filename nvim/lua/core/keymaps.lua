-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

-- Navigate quickfixlist
vim.keymap.set('n', '<leader>k', ':cprev<CR>')
vim.keymap.set('n', '<leader>j', ':cnext<CR>')

-- Explore
vim.keymap.set('n', '<leader>x', ':Ex<CR>')
vim.keymap.set('n', '<leader>vx', ':Vex<CR>')

-- Hover
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
    end
  end,
})

-- Navigate file
vim.keymap.set('n', '<c-u>', '<c-u>zz')
vim.keymap.set('n', '<c-d>', '<c-d>zz')

-- Search and replace 
vim.keymap.set('n', '<leader>r', ':%s//g<Left><Left>')

-- Search for selected text
vim.keymap.set('v', '<leader>/', 'y/<C-R>"<CR>')

-- Paste without changing register
vim.keymap.set('n', '<leader>p', '"_dP')

-- Copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y')
