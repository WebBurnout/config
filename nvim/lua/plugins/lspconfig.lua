
return {
  'neovim/nvim-lspconfig',
  lazy = false,
  config = function()

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings
        local opts = { buffer = ev.buf }
        
        -- Goto mappings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition', buffer = opts.buffer })
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to Declaration', buffer = opts.buffer })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to Implementation', buffer = opts.buffer })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to References', buffer = opts.buffer })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation', buffer = opts.buffer })

        -- Code actions and refactoring
        vim.keymap.set({ 'n', 'v' }, '<leader>c', vim.lsp.buf.code_action, { desc = 'Code Action', buffer = opts.buffer })
        -- vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename', buffer = opts.buffer })

        -- Diagnostics
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open Diagnostics List', buffer = opts.buffer })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })

      end
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = {
        border = 'rounded',
        source = 'if_many',
        max_width = 80,
      },
      underline = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      },
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    vim.lsp.enable('ts_ls')

    vim.lsp.enable("eslint")
    local base_on_attach = vim.lsp.config.eslint.on_attach
    vim.lsp.config("eslint", {
      on_attach = function(client, bufnr)
        if not base_on_attach then return end

        base_on_attach(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "LspEslintFixAll",
        })
      end,
    })

    vim.lsp.enable('pyright')

    vim.lsp.config('ruff', {
      init_options = {
        settings = {
          -- Server settings should go here
        }
      }
    })

    vim.lsp.config('emmet_language_server', {
      filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact" },
      -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
      -- **Note:** only the options listed in the table are supported.
      init_options = {
        ---@type table<string, string>
        includeLanguages = {},
        --- @type string[]
        excludeLanguages = {},
        --- @type string[]
        extensionsPath = {},
        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
        preferences = {},
        --- @type boolean Defaults to `true`
        showAbbreviationSuggestions = true,
        --- @type "always" | "never" Defaults to `"always"`
        showExpandedAbbreviation = "always",
        --- @type boolean Defaults to `false`
        showSuggestionsAsSnippets = false,
        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
        syntaxProfiles = {},
        --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
        variables = {},
      },
    })

  end,
}
