

-- Search and replace
return {
  'MagicDuck/grug-far.nvim',
  keys = {
    { '<Leader>R', ':GrugFar<cr>', { desc = 'Search and replace' } },
  },
  config = function()
    require('grug-far').setup({

    })
  end,
}
