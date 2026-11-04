vim.pack.add { 'https://github.com/delphinus/md-render.nvim' }

vim.keymap.set('n', '<leader>mp', '<Plug>(md-render-preview)', { desc = '[M]arkdown [P]review (split)' })
vim.keymap.set('n', '<leader>mt', '<Plug>(md-render-preview-tab)', { desc = '[M]arkdown preview ([T]ab)' })

require('which-key').add { { '<leader>m', group = '[M]arkdown' } }
