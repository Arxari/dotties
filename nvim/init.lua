-- Basics
vim.opt.number = true
vim.opt.clipboard = "unnamedplus"

-- Undo settings
vim.opt.undofile = true -- persistent undo
vim.opt.undodir = vim.fn.expand('~/.local/share/nvim/undo')

-- Key bindings
vim.keymap.set('n', '<C-s>', ':write<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<C-q>', ':quit<CR>', { desc = 'Quit Neovim' })
vim.keymap.set({ 'n', 'i' }, '<C-z>', '<Cmd>undo<CR>', { desc = 'Undo' })
vim.keymap.set({ 'n', 'i' }, '<C-y>', '<Cmd>redo<CR>', { desc = 'Redo' })
vim.keymap.set({ 'n', 'v' }, '<M-c>', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'i' }, '<M-v>', '<C-r>+', { desc = 'Paste from system clipboard' })

-- Automatically go into insert mode when opening a file
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.cmd("startinsert")
    end
})

-- Temporary normal mode
local temp_normal_mode = false

vim.keymap.set('i', '<C-o>', function()
    temp_normal_mode = true
    return '<Esc>'
end, { desc = 'Temporary normal mode', expr = true })

vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        vim.schedule(function()
            if temp_normal_mode then
                vim.cmd("startinsert")
                temp_normal_mode = false
            end
        end)
    end
})

-- Quick save
vim.keymap.set('n', 's', function()
    if temp_normal_mode then
        vim.cmd('write')
        vim.schedule(function()
            vim.cmd('startinsert')
            temp_normal_mode = false
        end)
    end
end, { desc = 'Quick save and return to insert' })

vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        vim.schedule(function()
            if temp_normal_mode then
                vim.cmd("startinsert")
                temp_normal_mode = false
            end
        end)
    end
})

-- Text replace
vim.api.nvim_create_user_command('Replace', function(opts)
    local args = vim.split(opts.args, ' ')
    if #args >= 2 then
        local search = args[1]
        local replace = table.concat(args, ' ', 2)
        vim.cmd(string.format('%%s/%s/%s/g', search, replace))
    else
        print("Usage: Replace [search] [replace]")
    end
end, {
    nargs = '+',
    desc = 'Replace text globally'
})

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy
require("config.lazy")
