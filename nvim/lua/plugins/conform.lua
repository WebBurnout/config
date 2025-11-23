return {
  'stevearc/conform.nvim',
  config = function()
    local conform = require("conform")

    -- Define Ruff formatter using uv
    conform.formatters.ruff_format = {
      command = "uv",
      args = { "run", "ruff", "format", "--stdin-filename", "$FILENAME", "-" },
      stdin = true,
    }

    conform.formatters.ruff_fix = {
      command = "uv",
      args = { "run", "ruff", "check", "--fix", "--stdin-filename", "$FILENAME", "-" },
      stdin = true,
    }

    -- Setup Conform
    conform.setup({
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    })

    -- Optional keymap for manual formatting
    vim.keymap.set({ "n", "v" }, "<leader>l", function()
      conform.format({ async = true, lsp_fallback = true })
    end, { desc = "Format buffer with Ruff" })
  end
}
