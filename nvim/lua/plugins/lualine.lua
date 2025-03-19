
-- status line
return {
  'nvim-lualine/lualine.nvim',

  dependencies = { 'nvim-tree/nvim-web-devicons' },

  config = function()

    -- hide vim's mode which is duplicate
    vim.opt.showmode = false

    require('lualine').setup {
      options = {
        disabled_filetypes = { 'neo-tree' },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {
          'branch', 
          {
            'diff',
            -- color = { bg = 'grey', }
            colored = false, 
          },
         'diagnostics',
        },
        lualine_c = {'filename'},

        lualine_x = {'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},

        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
    }
  end,
}
