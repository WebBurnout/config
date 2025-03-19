

-- Search and replace
return {
  'MagicDuck/grug-far.nvim',
  keys = {
    { '<Leader>r', ':GrugFar<cr>', { desc = 'Search and replace' } },
  },
  config = function()

    require('grug-far').setup({

    })
  end,
}
