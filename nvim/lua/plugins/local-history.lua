
-- History of every save
return {
  'dinhhuy258/vim-local-history',
  lazy = false,
  branch = "master",
  build = ":UpdateRemotePlugins",
  keys = {
    { '<Leader>y', ':LocalHistoryToggle<CR>', { desc = 'Toggle local history' } },
  },
  config = function()
    vim.g.local_history_path = '/Users/tim/tmp'
    vim.g.local_history_max_changes = 100
  end,
}
