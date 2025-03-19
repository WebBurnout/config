

-- Solarized color scheme
return {
  'ishan9299/nvim-solarized-lua',
  lazy = false,
  priority = 1000,
  opts = {
   transparent = {
      enabled = true,
    },
  },
  config = function(_, opts)
    vim.o.termguicolors = true
    vim.o.background = 'dark'
    vim.cmd.colorscheme 'solarized'
  end,
}
