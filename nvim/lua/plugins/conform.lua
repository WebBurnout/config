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

    -- Define oxfmt formatter
    conform.formatters.oxfmt = {
      command = "oxfmt",
      args = { "--write", "$FILENAME" },
      stdin = false,
    }

    -- Setup Conform
    conform.setup({
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
      },
      format_on_save = function(bufnr)
        -- Only use LSP fallback if the LSP client is actually attached and running
        local lsp_clients = vim.lsp.get_clients({ bufnr = bufnr })
        local has_valid_lsp = false
        for _, client in ipairs(lsp_clients) do
          if client.server_capabilities.documentFormattingProvider then
            has_valid_lsp = true
            break
          end
        end
        
        return {
          timeout_ms = 500,
          lsp_fallback = has_valid_lsp,
        }
      end,
    })

    -- Optional keymap for manual formatting
    vim.keymap.set({ "n", "v" }, "<leader>l", function()
      conform.format({ async = true, lsp_fallback = false })
    end, { desc = "Format buffer" })
  end
}
