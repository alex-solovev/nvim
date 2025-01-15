-- Fix for https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight

require('config.lazy')

require('oil').setup({
  columns = {
    'icon',
    'permissions',
    -- 'size',
    -- 'mtime',
  },
})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- Basic formatting and line numbers
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable paste from clipboard
vim.opt.clipboard = 'unnamedplus'


print('Ready to rock!')
