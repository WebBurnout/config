
return {
  "catppuccin/nvim",
  priority = 1000,
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup({
      flavor = 'mocha',

      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay1 },
          -- This appears to be a bug in marks plugin but anyway this fixes it
          MarkSignNumHL = { fg = colors.overlay1 },
        }
      end

    })
    vim.cmd.colorscheme 'catppuccin'
  end,
}

