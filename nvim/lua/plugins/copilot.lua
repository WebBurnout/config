
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
        vim.keymap.set("n", "<C-l>", function() require("copilot.panel").accept() end, { expr = true, desc = "Accept Copilot suggestion" })
      end,
    })

    require('copilot').setup {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
        },
      },
      filetypes = {
        markdown = false,
        ["*"] = true,
      },
    }
  end,
}
