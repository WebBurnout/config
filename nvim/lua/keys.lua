


vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('i', '<Esc>', '`')

vim.keymap.set('n', '<Leader><space>', ':noh<cr>', { silent = true })

vim.keymap.set('n', '<leader>c', '"+yy', { desc = 'Copy line to system clipboard' })
vim.keymap.set('v', '<leader>c', '"+y', { desc = 'Copy to system clipboard' })

vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
