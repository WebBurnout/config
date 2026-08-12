
return {
  "catppuccin/nvim",
  priority = 1000,
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup({
      flavor = 'mocha',
    transparent_background = true,
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay1 },
          -- This appears to be a bug in marks plugin but anyway this fixes it
          MarkSignNumHL = { fg = colors.overlay1 },
        }
      end

    })
    vim.cmd.colorscheme 'catppuccin'

    -- Dim while the tmux pane is unfocused. tmux's window-style can't do this
    -- for us: nvim paints every cell with an explicit fg, never the default one.
    local dim_ns = vim.api.nvim_create_namespace('dim-unfocused')
    local base = { 0x1e, 0x1e, 0x2e } -- transparent_background leaves Normal bg unset
    local keep = 0.8

    vim.api.nvim_create_autocmd('FocusLost', {
      callback = function()
        for name in pairs(vim.api.nvim_get_hl(0, {})) do
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          if hl.fg then
            local dimmed = 0
            for i = 1, 3 do
              local channel = math.floor(hl.fg / 256 ^ (3 - i)) % 256
              dimmed = dimmed * 256 + math.floor(channel * keep + base[i] * (1 - keep) + 0.5)
            end
            hl.fg = dimmed
            vim.api.nvim_set_hl(dim_ns, name, hl)
          end
        end
        vim.api.nvim_set_hl_ns(dim_ns)
      end,
    })

    vim.api.nvim_create_autocmd('FocusGained', {
      callback = function() vim.api.nvim_set_hl_ns(0) end,
    })
  end,
}

