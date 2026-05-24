
return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  config = function()
    require('copilot').setup {
      panel = { enabled = false },
      suggestion = { enabled = false },  -- Disable native suggestions - using blink-cmp-copilot instead
      filetypes = {
        markdown = false,
        ["*"] = true,
      },
    }
  end,
}
