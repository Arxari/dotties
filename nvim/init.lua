-- Basics
vim.opt.number = true

-- Key bindings
vim.keymap.set('n', '<C-s>', ':write<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<C-q>', ':quit<CR>', { desc = 'Quit Neovim' })

-- Automatically go into insert mode when opening a file
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.cmd("startinsert")
  end
})

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy
require("config.lazy")
