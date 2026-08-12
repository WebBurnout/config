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

    -- Only format JS/TS when the project opts in with an oxfmt/oxlint config.
    -- Otherwise oxfmt's defaults mangle random files we just happen to open.
    local oxfmt_config_files = {
      ".oxfmtrc.json",
      ".oxfmtrc.jsonc",
      "oxfmt.json",
      "oxfmt.jsonc",
      ".oxlintrc.json",
      ".oxlintrc.jsonc",
      "oxlint.json",
      "oxlintrc.json",
    }

    local function has_oxfmt_config(ctx)
      local dir = vim.fs.dirname(ctx.filename)
      if not dir or dir == "" then
        return false
      end
      local found = vim.fs.find(oxfmt_config_files, { path = dir, upward = true, type = "file" })
      return #found > 0
    end

    -- Define oxfmt formatter
    conform.formatters.oxfmt = {
      command = "oxfmt",
      args = { "--write", "$FILENAME" },
      stdin = false,
      condition = function(_, ctx)
        return has_oxfmt_config(ctx)
      end,
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
      -- No LSP fallback: otherwise the TS language server formats with its own
      -- defaults whenever oxfmt opts out, which is the thing we're avoiding.
      -- quiet: no-config JS/TS buffers legitimately have nothing to run,
      -- don't warn about it on every write.
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "never",
        quiet = true,
      },
    })

    -- Optional keymap for manual formatting
    vim.keymap.set({ "n", "v" }, "<leader>l", function()
      conform.format({ async = false, timeout_ms = 500, lsp_format = "never" })
    end, { desc = "Format buffer" })
  end
}
