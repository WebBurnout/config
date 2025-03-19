-- tab is two spaces
vim.opt.tabstop = 2

-- convert tab to spaces
vim.opt.expandtab = true

-- when indenting with '>', use 2 spaces
vim.opt.shiftwidth = 2

-- change working directory to the current file
vim.opt.autochdir = true

-- set the title of terminal
vim.opt.title = true

-- line numbers
vim.opt.number = true

-- if you try to move off a buffer with unsaved changes it will prompt you
vim.opt.hidden = false

-- writes files when switching buffers
vim.opt.autowrite = true

-- reloads the buffer if its changed on disk
vim.opt.autoread = true


-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Use a more comprehensive set of events to detect focus changes
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "VimResume", "TabEnter", "TermLeave"}, {
  pattern = "*",
  callback = function()
    if vim.api.nvim_get_mode().mode ~= 'c' then
      vim.cmd('checktime')
    end
  end
})

-- notification after file change
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.api.nvim_echo({{
      "File changed on disk. Buffer reloaded.",
      "WarningMsg"
    }}, true, {})
  end
})

-- Set a shorter updatetime to make CursorHold trigger more frequently
vim.opt.updatetime = 1000


vim.opt.undodir = '/Users/tim/.vim-undo-dir'
vim.opt.undofile = true

-- ignore case in search unless there is a capital letter
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- highlight 80 characters mark
vim.opt.cc = '80'

-- changes to working dir to that of current file
vim.opt.autochdir = true

-- sign column is always present, always has space for git signs and disagnostics
vim.opt.signcolumn = 'yes:2'

-- moves cursor to previous line with back/forward movement
vim.opt.whichwrap:append {
  ['<'] = true,
  ['>'] = true,
  ['['] = true,
  [']'] = true,
  h = true,
  l = true,
}

-- Open new split panes to right and bottom, which feels more natural than
-- Vim’s default
vim.opt.splitright = true
vim.opt.splitbelow = true



-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }


-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

require('keys')

require('lazy-setup')
