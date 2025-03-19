
return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  config = function()
    require('copilot').setup {
      panel = {
        enabled = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
        },
      },
      -- server_opts_overrides = {
      --   -- trace = "verbose",
      --   settings = {
      --     advanced = {
      --       -- listCount = 10, -- #completions for panel
      --       inlineSuggestCount = 3, -- #completions for getCompletions
      --     },
      --   },
      -- },
      filetypes = {
        markdown = false,
        typescript = true,
        ["*"] = true,
      },
    }
  end,
}
