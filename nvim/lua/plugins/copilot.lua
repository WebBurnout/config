
return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuClose",
      callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
    })

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
      filetypes = {
        markdown = false,
        typescript = true,
        ["*"] = true,
      },
    }
  end,
}
